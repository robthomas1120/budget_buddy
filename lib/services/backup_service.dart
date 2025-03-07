import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class BackupService {
  static final BackupService instance = BackupService._init();

  BackupService._init();

  // Check permissions - simplified for iOS
  Future<bool> _checkPermissions() async {
    // iOS handles permissions differently - usually just needs to request when sharing
    if (Platform.isIOS) {
      return true;
    }
    
    // For Android, we still need to request explicit permissions
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      var externalStatus = await Permission.manageExternalStorage.status;
      if (!externalStatus.isGranted) {
        externalStatus = await Permission.manageExternalStorage.request();
      }
      return status.isGranted && externalStatus.isGranted;
    }
    
    return true;
  }

  // Get the documents directory path (works well for iOS)
  Future<String> get _documentsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Create a backup file with all transactions and accounts
  Future<String?> createBackup(BuildContext context) async {
    try {
      if (!await _checkPermissions()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required for backup')),
        );
        return null;
      }

      // Get all transactions and accounts
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      
      // Convert to JSON
      final List<Map<String, dynamic>> transactionJsonList = 
          transactions.map((transaction) => transaction.toMap()).toList();
      
      final List<Map<String, dynamic>> accountJsonList = 
          accounts.map((account) => account.toMap()).toList();
      
      final String jsonData = json.encode({
        'transactions': transactionJsonList,
        'accounts': accountJsonList,
        'version': 2, // Increased version to indicate new format with accounts
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'app': 'Budget_Buddy',
      });
      
      // Save to file
      final String documentsPath = await _documentsPath;
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '$documentsPath/budget_buddy_backup_$timestamp.json';
      
      final File file = File(filePath);
      await file.writeAsString(jsonData);
      
      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Budget Buddy Backup');
      
      return filePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating backup: ${e.toString()}')),
      );
      return null;
    }
  }

  // Restore from a backup file
  Future<bool> restoreBackup(BuildContext context) async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return false;
      }
      
      final String? filePath = result.files.first.path;
      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid file selected')),
        );
        return false;
      }
      
      final File file = File(filePath);
      
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup file not found')),
        );
        return false;
      }
      
      // Read and parse JSON
      final String jsonData = await file.readAsString();
      final Map<String, dynamic> backupData = json.decode(jsonData);
      
      // Check app identifier if present
      if (backupData.containsKey('app') && backupData['app'] != 'Budget_Buddy') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This backup is from a different app')),
        );
        return false;
      }

      // Handle version 1 backups (old format without accounts)
      if (backupData.containsKey('version') && backupData['version'] == 1) {
        if (!backupData.containsKey('data')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid backup file format')),
          );
          return false;
        }

        // Clear existing data
        await DatabaseHelper.instance.deleteAllTransactions();
        
        // Get default account (or create one if none exists)
        List<Account> accounts = await DatabaseHelper.instance.getAllAccounts();
        int defaultAccountId;
        
        if (accounts.isEmpty) {
          defaultAccountId = await DatabaseHelper.instance.insertAccount(
            Account(
              name: 'Cash',
              type: 'cash',
              balance: 0.0,
            )
          );
        } else {
          defaultAccountId = accounts[0].id!;
        }
        
        // Restore transactions, associating them with the default account
        final List<dynamic> jsonList = backupData['data'];
        for (var item in jsonList) {
          final transactionMap = Map<String, dynamic>.from(item);
          // Add account_id to the transaction
          transactionMap['account_id'] = defaultAccountId;
          final Transaction transaction = Transaction.fromMap(transactionMap);
          await DatabaseHelper.instance.insertTransaction(transaction);
        }
        
        return true;
      }
      
      // Handle version 2 backups (new format with accounts)
      if (backupData.containsKey('version') && backupData['version'] == 2) {
        if (!backupData.containsKey('transactions') || !backupData.containsKey('accounts')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid backup file format')),
          );
          return false;
        }

        // Clear existing data
        await DatabaseHelper.instance.deleteAllTransactions();
        
        // Get current accounts to delete them
        List<Account> currentAccounts = await DatabaseHelper.instance.getAllAccounts();
        for (var account in currentAccounts) {
          try {
            await DatabaseHelper.instance.deleteAccount(account.id!);
          } catch (e) {
            // Skip if can't delete (might have transactions)
          }
        }
        
        // First restore accounts
        final List<dynamic> accountJsonList = backupData['accounts'];
        Map<int, int> accountIdMapping = {}; // Map old IDs to new IDs
        
        for (var item in accountJsonList) {
          final Account account = Account.fromMap(item);
          final oldId = account.id;
          
          // Create a copy without the ID to get a new ID assigned
          final newAccount = Account(
            name: account.name,
            type: account.type,
            iconName: account.iconName,
            balance: 0.0, // Start with zero balance, will be recalculated by transactions
          );
          
          final newId = await DatabaseHelper.instance.insertAccount(newAccount);
          if (oldId != null) {
            accountIdMapping[oldId] = newId;
          }
        }
        
        // Then restore transactions with updated account IDs
        final List<dynamic> transactionJsonList = backupData['transactions'];
        for (var item in transactionJsonList) {
          final transactionMap = Map<String, dynamic>.from(item);
          
          // Update account ID reference if needed
          if (transactionMap.containsKey('account_id') && transactionMap['account_id'] != null) {
            final oldAccountId = transactionMap['account_id'];
            if (accountIdMapping.containsKey(oldAccountId)) {
              transactionMap['account_id'] = accountIdMapping[oldAccountId];
            } else {
              // If can't find mapped account, use the first available account
              final accounts = await DatabaseHelper.instance.getAllAccounts();
              if (accounts.isNotEmpty) {
                transactionMap['account_id'] = accounts[0].id;
              } else {
                transactionMap['account_id'] = null;
              }
            }
          }
          
          final Transaction transaction = Transaction.fromMap(transactionMap);
          await DatabaseHelper.instance.insertTransaction(transaction);
        }
        
        return true;
      }
      
      // If we get here, the backup format is unknown
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported backup file version')),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring backup: ${e.toString()}')),
      );
      return false;
    }
  }

  // Export transactions and accounts to CSV
  Future<String?> exportToCSV(BuildContext context) async {
    try {
      // Get all transactions and accounts
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      
      // Create a map of account IDs to names for easy lookup
      Map<int?, String> accountNames = {};
      for (var account in accounts) {
        if (account.id != null) {
          accountNames[account.id] = account.name;
        }
      }
      
      // Create CSV data for transactions
      List<List<dynamic>> transactionCsvData = [];
      
      // Add header
      transactionCsvData.add([
        'ID', 'Title', 'Amount', 'Type', 'Category', 'Date', 'Notes', 'Account'
      ]);
      
      // Add rows
      for (var transaction in transactions) {
        String accountName = 'Unknown';
        if (transaction.accountId != null && accountNames.containsKey(transaction.accountId)) {
          accountName = accountNames[transaction.accountId]!;
        }
        
        transactionCsvData.add([
          transaction.id,
          transaction.title,
          transaction.amount,
          transaction.type,
          transaction.category,
          DateFormat('yyyy-MM-dd HH:mm').format(transaction.date),
          transaction.notes ?? '',
          accountName
        ]);
      }
      
      // Create CSV data for accounts
      List<List<dynamic>> accountCsvData = [];
      
      // Add header
      accountCsvData.add([
        'ID', 'Name', 'Type', 'Balance'
      ]);
      
      // Add rows
      for (var account in accounts) {
        accountCsvData.add([
          account.id,
          account.name,
          account.type,
          account.balance
        ]);
      }
      
      // Convert to CSV string
      String transactionsCsv = const ListToCsvConverter().convert(transactionCsvData);
      String accountsCsv = const ListToCsvConverter().convert(accountCsvData);
      
      // Save to files
      final String documentsPath = await _documentsPath;
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      final String transactionsFilePath = '$documentsPath/budget_buddy_transactions_$timestamp.csv';
      final String accountsFilePath = '$documentsPath/budget_buddy_accounts_$timestamp.csv';
      
      final File transactionsFile = File(transactionsFilePath);
      await transactionsFile.writeAsString(transactionsCsv);
      
      final File accountsFile = File(accountsFilePath);
      await accountsFile.writeAsString(accountsCsv);
      
      // Share both files
      await Share.shareXFiles(
        [XFile(transactionsFilePath), XFile(accountsFilePath)], 
        text: 'Budget Buddy Data Export'
      );
      
      return transactionsFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: ${e.toString()}')),
      );
      return null;
    }
  }
}