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

  // Create a backup file with all transactions
  Future<String?> createBackup(BuildContext context) async {
    try {
      if (!await _checkPermissions()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required for backup')),
        );
        return null;
      }

      // Get all transactions
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      
      // Convert to JSON
      final List<Map<String, dynamic>> jsonList = 
          transactions.map((transaction) => transaction.toMap()).toList();
      final String jsonData = json.encode({
        'data': jsonList,
        'version': 1,
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
      
      if (!backupData.containsKey('data') || !backupData.containsKey('version')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid backup file format')),
        );
        return false;
      }
      
      // Check app identifier if present
      if (backupData.containsKey('app') && backupData['app'] != 'Budget_Buddy') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This backup is from a different app')),
        );
        return false;
      }
      
      // Clear existing data
      await DatabaseHelper.instance.deleteAllTransactions();
      
      // Restore transactions
      final List<dynamic> jsonList = backupData['data'];
      for (var item in jsonList) {
        final Transaction transaction = Transaction.fromMap(item);
        await DatabaseHelper.instance.insertTransaction(transaction);
      }
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring backup: ${e.toString()}')),
      );
      return false;
    }
  }

  // Export transactions to CSV
  Future<String?> exportToCSV(BuildContext context) async {
    try {
      // Get all transactions
      final transactions = await DatabaseHelper.instance.getAllTransactions();
      
      // Create CSV data
      List<List<dynamic>> csvData = [];
      
      // Add header
      csvData.add([
        'ID', 'Title', 'Amount', 'Type', 'Category', 'Date', 'Notes'
      ]);
      
      // Add rows
      for (var transaction in transactions) {
        csvData.add([
          transaction.id,
          transaction.title,
          transaction.amount,
          transaction.type,
          transaction.category,
          DateFormat('yyyy-MM-dd HH:mm').format(transaction.date),
          transaction.notes ?? ''
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Save to file
      final String documentsPath = await _documentsPath;
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '$documentsPath/budget_buddy_export_$timestamp.csv';
      
      final File file = File(filePath);
      await file.writeAsString(csv);
      
      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: 'Budget Buddy Data Export');
      
      return filePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: ${e.toString()}')),
      );
      return null;
    }
  }
}