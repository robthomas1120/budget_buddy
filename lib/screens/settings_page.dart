import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/backup_service.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to profile settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to categories settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup & Restore'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              _showBackupRestoreOptions(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Export Data'),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              _showExportOptions(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Clear All Data'),
            trailing: Icon(Icons.warning, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear All Data?'),
                  content: Text(
                      'This will permanently delete all your transactions. This action cannot be undone.'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteAllTransactions();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('All data has been deleted')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Budget Buddy v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showBackupRestoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.save, color: Colors.blue),
            title: Text('Create Backup'),
            subtitle: Text('Save all your data to a file'),
            onTap: () async {
              // Close the bottom sheet first
              Navigator.pop(bottomSheetContext);
              
              // Use the original context for dialog
              BuildContext dialogContext = context;
              
              // Show loading indicator
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) {
                  dialogContext = loadingContext; // Store the loading dialog context
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              
              final filePath = await BackupService.instance.createBackup(context);
              
              // Hide loading indicator using the stored context
              Navigator.of(dialogContext).pop();
              
              if (filePath != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backup created and ready to share')),
                );
              }
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.restore, color: Colors.orange),
            title: Text('Restore from Backup'),
            subtitle: Text('Load data from a backup file'),
            onTap: () async {
              // Close the bottom sheet
              Navigator.pop(bottomSheetContext);
              
              // Confirm restore
              bool shouldRestore = await showDialog(
                context: context,
                builder: (BuildContext alertContext) {
                  return AlertDialog(
                    title: Text('Restore from Backup'),
                    content: Text(
                      'This will replace all your current data with the data from the backup file. Continue?'
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(alertContext, false),
                      ),
                      TextButton(
                        child: Text('Restore'),
                        onPressed: () => Navigator.pop(alertContext, true),
                      ),
                    ],
                  );
                },
              ) ?? false;
              
              if (!shouldRestore) return;
              
              // Use a new variable for loading dialog context
              BuildContext dialogContext = context;
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) {
                  dialogContext = loadingContext; // Store the context
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              
              final success = await BackupService.instance.restoreBackup(context);
              
              // Hide loading indicator using the stored context
              Navigator.of(dialogContext).pop();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data restored successfully')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.table_chart, color: Colors.green),
            title: Text('Export as CSV'),
            subtitle: Text('Export data for spreadsheet applications'),
            onTap: () async {
              // Close the bottom sheet first
              Navigator.pop(bottomSheetContext);
              
              // Store the context for the loading dialog
              BuildContext dialogContext = context;
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) {
                  dialogContext = loadingContext; // Store the loading dialog context
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              
              final filePath = await BackupService.instance.exportToCSV(context);
              
              // Hide loading indicator using the stored context
              if (dialogContext != null) {
                Navigator.of(dialogContext).pop();
              }
              
              if (filePath != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data exported and ready to share')),
                );
              }
            },
          ),
          // You can add more export options here in the future
        ],
      ),
    );
  }
}