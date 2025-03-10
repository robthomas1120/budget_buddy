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
import '../models/budget.dart';
import '../models/savings_goal.dart';
import 'package:flutter/cupertino.dart';

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
        _showErrorMessage(context, 'Storage permission is required for backup');
        return null;
      }

      // Show loading indicator
      _showLoadingDialog(context, 'Creating backup...');

      // Get all transactions and accounts
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      final budgets = await DatabaseHelper.instance.getAllBudgets();
      final savingsGoals = await DatabaseHelper.instance.getAllSavingsGoals();
      
      // Convert to JSON
      final List<Map<String, dynamic>> transactionJsonList = 
          transactions.map((transaction) => transaction.toMap()).toList();
      
      final List<Map<String, dynamic>> accountJsonList = 
          accounts.map((account) => account.toMap()).toList();
      
      final List<Map<String, dynamic>> budgetJsonList = 
          budgets.map((budget) => budget.toMap()).toList();
      
      final List<Map<String, dynamic>> savingsJsonList = 
          savingsGoals.map((goal) => goal.toMap()).toList();
      
      final String jsonData = json.encode({
        'transactions': transactionJsonList,
        'accounts': accountJsonList,
        'budgets': budgetJsonList,
        'savings_goals': savingsJsonList,
        'version': 3, // Increased version to indicate new format with budgets and savings
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'app': 'Budget_Buddy',
      });
      
      // Save to file
      final String documentsPath = await _documentsPath;
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '$documentsPath/budget_buddy_backup_$timestamp.json';
      
      final File file = File(filePath);
      await file.writeAsString(jsonData);
      
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Budget Buddy Backup');
      
      // Show success message
      _showSuccessMessage(context, 'Backup created successfully');
      
      return filePath;
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      _showErrorMessage(context, 'Error creating backup: ${e.toString()}');
      return null;
    }
  }

  // Export transactions to CSV
  Future<String?> exportToCSV(BuildContext context) async {
    try {
      if (!await _checkPermissions()) {
        _showErrorMessage(context, 'Storage permission is required for export');
        return null;
      }

      // Show loading indicator
      _showLoadingDialog(context, 'Exporting data...');

      // Get all transactions
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      
      // Get all accounts for mapping
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      final accountMap = {for (var account in accounts) account.id: account.name};
      
      // Prepare CSV data
      List<List<dynamic>> csvData = [];
      
      // Add header row
      csvData.add([
        'Date', 
        'Type', 
        'Category', 
        'Description', 
        'Amount', 
        'Account'
      ]);
      
      // Add transaction rows
      for (var transaction in transactions) {
        final date = DateFormat('yyyy-MM-dd').format(transaction.date);
        final type = transaction.type.toUpperCase();
        final category = transaction.category;
        final description = transaction.title;
        final amount = transaction.amount.toStringAsFixed(2);
        final accountName = accountMap[transaction.accountId] ?? 'Unknown';
        
        csvData.add([
          date,
          type,
          category,
          description,
          amount,
          accountName
        ]);
      }
      
      // Convert to CSV
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Save to file
      final String documentsPath = await _documentsPath;
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '$documentsPath/budget_buddy_export_$timestamp.csv';
      
      final File file = File(filePath);
      await file.writeAsString(csv);
      
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Budget Buddy Export');
      
      // Show success message
      _showSuccessMessage(context, 'Data exported successfully');
      
      return filePath;
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      _showErrorMessage(context, 'Error exporting data: ${e.toString()}');
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
        _showErrorMessage(context, 'Invalid file selected');
        return false;
      }
      
      final File file = File(filePath);
      
      if (!await file.exists()) {
        _showErrorMessage(context, 'Backup file not found');
        return false;
      }
      
      // Show confirmation dialog
      final bool shouldProceed = await _showRestoreConfirmationDialog(context);
      if (!shouldProceed) {
        return false;
      }
      
      // Show loading indicator
      _showLoadingDialog(context, 'Restoring data...');
      
      // Read and parse JSON
      final String jsonData = await file.readAsString();
      final Map<String, dynamic> backupData = json.decode(jsonData);
      
      // Check app identifier if present
      if (backupData.containsKey('app') && backupData['app'] != 'Budget_Buddy') {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorMessage(context, 'This backup is from a different app');
        return false;
      }

      // Handle version 1 backups (old format without accounts)
      if (backupData.containsKey('version') && backupData['version'] == 1) {
        if (!backupData.containsKey('data')) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          _showErrorMessage(context, 'Invalid backup file format');
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
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        _showSuccessMessage(context, 'Backup restored successfully');
        return true;
      }
      
      // Handle version 2 backups (format with accounts)
      if (backupData.containsKey('version') && backupData['version'] == 2) {
        if (!backupData.containsKey('transactions') || !backupData.containsKey('accounts')) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          _showErrorMessage(context, 'Invalid backup file format');
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
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        _showSuccessMessage(context, 'Backup restored successfully');
        return true;
      }
      
      // Handle version 3 backups (format with accounts, budgets, and savings)
      if (backupData.containsKey('version') && backupData['version'] == 3) {
        if (!backupData.containsKey('transactions') || !backupData.containsKey('accounts')) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          _showErrorMessage(context, 'Invalid backup file format');
          return false;
        }

        // Clear existing data
        await DatabaseHelper.instance.deleteAllTransactions();
        await DatabaseHelper.instance.deleteAllBudgets();
        await DatabaseHelper.instance.deleteAllSavingsGoals();
        
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
          final accountMap = Map<String, dynamic>.from(item);
          final oldId = accountMap['id'];
          
          // Remove ID to get a new one assigned
          accountMap.remove('id');
          final Account account = Account.fromMap(accountMap);
          
          final newId = await DatabaseHelper.instance.insertAccount(account);
          if (oldId != null) {
            accountIdMapping[oldId] = newId;
          }
        }
        
        // Restore budgets if present
        if (backupData.containsKey('budgets')) {
          final List<dynamic> budgetJsonList = backupData['budgets'];
          for (var item in budgetJsonList) {
            try {
              final budgetMap = Map<String, dynamic>.from(item);
              // Remove ID to get a new one assigned
              budgetMap.remove('id');
              
              // Make sure date fields are properly formatted as milliseconds since epoch
              if (budgetMap.containsKey('start_date') && budgetMap['start_date'] is! int) {
                budgetMap['start_date'] = DateTime.parse(budgetMap['start_date'].toString()).millisecondsSinceEpoch;
              }
              
              if (budgetMap.containsKey('end_date') && budgetMap['end_date'] is! int) {
                budgetMap['end_date'] = DateTime.parse(budgetMap['end_date'].toString()).millisecondsSinceEpoch;
              }
              
              // Update account IDs reference if needed
              if (budgetMap.containsKey('account_ids') && budgetMap['account_ids'] != null) {
                final String accountIdsStr = budgetMap['account_ids'].toString();
                if (accountIdsStr.isNotEmpty) {
                  List<String> oldAccountIdsList = accountIdsStr.split(',');
                  List<int> newAccountIdsList = [];
                  
                  for (String oldIdStr in oldAccountIdsList) {
                    int oldId = int.parse(oldIdStr);
                    if (accountIdMapping.containsKey(oldId)) {
                      newAccountIdsList.add(accountIdMapping[oldId]!);
                    }
                  }
                  
                  if (newAccountIdsList.isNotEmpty) {
                    budgetMap['account_ids'] = newAccountIdsList.join(',');
                  }
                }
              }
              
              final budget = Budget.fromMap(budgetMap);
              await DatabaseHelper.instance.insertBudget(budget);
            } catch (e) {
              print('Error restoring budget: $e');
              // Continue with next budget
            }
          }
        }
        
        // Restore savings goals if present
        if (backupData.containsKey('savings_goals')) {
          final List<dynamic> savingsJsonList = backupData['savings_goals'];
          for (var item in savingsJsonList) {
            try {
              final savingsMap = Map<String, dynamic>.from(item);
              // Remove ID to get a new one assigned
              savingsMap.remove('id');
              
              // Make sure date fields are properly formatted as milliseconds since epoch
              if (savingsMap.containsKey('start_date') && savingsMap['start_date'] is! int) {
                savingsMap['start_date'] = DateTime.parse(savingsMap['start_date'].toString()).millisecondsSinceEpoch;
              }
              
              if (savingsMap.containsKey('target_date') && savingsMap['target_date'] is! int) {
                savingsMap['target_date'] = DateTime.parse(savingsMap['target_date'].toString()).millisecondsSinceEpoch;
              }
              
              // Update account ID reference if needed
              if (savingsMap.containsKey('account_id') && savingsMap['account_id'] != null) {
                final oldAccountId = savingsMap['account_id'];
                if (accountIdMapping.containsKey(oldAccountId)) {
                  savingsMap['account_id'] = accountIdMapping[oldAccountId];
                }
              }
              
              final savingsGoal = SavingsGoal.fromMap(savingsMap);
              await DatabaseHelper.instance.insertSavingsGoal(savingsGoal);
            } catch (e) {
              print('Error restoring savings goal: $e');
              // Continue with next savings goal
            }
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
          
          // Remove ID to get a new one assigned
          transactionMap.remove('id');
          final Transaction transaction = Transaction.fromMap(transactionMap);
          await DatabaseHelper.instance.insertTransaction(transaction);
        }
        
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        _showSuccessMessage(context, 'Backup restored successfully');
        return true;
      }
      
      // If we get here, the backup format is unknown
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorMessage(context, 'Unsupported backup file version');
      return false;
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      _showErrorMessage(context, 'Error restoring backup: ${e.toString()}');
      return false;
    }
  }
  
  // Helper method to show a loading dialog
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black,
            fontFamily: '.SF Pro Text',
            fontSize: 16,
          ),
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Text(message),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to show an error message
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Helper method to show a success message
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Helper method to show a restore confirmation dialog
  Future<bool> _showRestoreConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontFamily: '.SF Pro Text',
            fontSize: 16,
          ),
          child: CupertinoAlertDialog(
            title: const Text('Restore Backup'),
            content: const Text(
              'This will replace all your current data with the backup data. This action cannot be undone. Are you sure you want to proceed?'
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Restore'),
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }
}