import 'package:flutter/cupertino.dart';
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
            leading: Icon(CupertinoIcons.person_fill),
            title: Text('Profile'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () {
              // Navigate to profile settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.tag_fill),
            title: Text('Categories'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () {
              // Navigate to categories settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.bell_fill),
            title: Text('Notifications'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () {
              // Navigate to notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.arrow_clockwise),
            title: Text('Backup & Restore'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () {
              _showBackupRestoreOptions(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.square_arrow_right),
            title: Text('Export Data'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () async {
              _showExportOptions(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
            title: Text('Clear All Data'),
            trailing: Icon(CupertinoIcons.chevron_right),
            onTap: () {
              _showClearDataDialog(context);
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
    showCupertinoModalPopup(
      context: context,
      builder: (bottomSheetContext) => CupertinoActionSheet(
        title: Text('Backup & Restore'),
        message: Text('Choose an option'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Create Backup'),
            onPressed: () async {
              Navigator.pop(bottomSheetContext);
              
              // Show loading indicator
              BuildContext dialogContext = context;
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) {
                  dialogContext = loadingContext;
                  return CupertinoAlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(),
                        SizedBox(height: 10),
                        Text('Creating backup...'),
                      ],
                    ),
                  );
                },
              );
              
              final filePath = await BackupService.instance.createBackup(context);
              
              // Hide loading indicator
              Navigator.of(dialogContext).pop();
              
              if (filePath != null) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    message: Text('Backup created and ready to share'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Restore from Backup'),
            onPressed: () async {
              Navigator.pop(bottomSheetContext);
              
              // Confirm restore
              bool shouldRestore = await showCupertinoDialog<bool>(
                context: context,
                builder: (alertContext) => CupertinoAlertDialog(
                  title: Text('Restore from Backup'),
                  content: Text(
                    'This will replace all your current data with the data from the backup file. Continue?'
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(alertContext, false),
                    ),
                    CupertinoDialogAction(
                      child: Text('Restore'),
                      onPressed: () => Navigator.pop(alertContext, true),
                    ),
                  ],
                ),
              ) ?? false;
              
              if (!shouldRestore) return;
              
              // Show loading indicator
              BuildContext dialogContext = context;
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) {
                  dialogContext = loadingContext;
                  return CupertinoAlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(),
                        SizedBox(height: 10),
                        Text('Restoring data...'),
                      ],
                    ),
                  );
                },
              );
              
              final success = await BackupService.instance.restoreBackup(context);
              
              // Hide loading indicator
              Navigator.of(dialogContext).pop();
              
              if (success) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    message: Text('Data restored successfully'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(bottomSheetContext),
          child: Text('Cancel'),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (bottomSheetContext) => CupertinoActionSheet(
        title: Text('Export Data'),
        message: Text('Choose a format'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Export as CSV'),
            onPressed: () async {
              Navigator.pop(bottomSheetContext);
              
              // Show loading indicator
              BuildContext dialogContext = context;
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) {
                  dialogContext = loadingContext;
                  return CupertinoAlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(),
                        SizedBox(height: 10),
                        Text('Exporting data...'),
                      ],
                    ),
                  );
                },
              );
              
              final filePath = await BackupService.instance.exportToCSV(context);
              
              // Hide loading indicator
              Navigator.of(dialogContext).pop();
              
              if (filePath != null) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    message: Text('Data exported and ready to share'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(bottomSheetContext),
          child: Text('Cancel'),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Clear All Data?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all your transactions. This action cannot be undone.',
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.black.withOpacity(0.8),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Delete'),
            onPressed: () async {
              await DatabaseHelper.instance.deleteAllTransactions();
              Navigator.of(context).pop();
              
              // Show iOS-style confirmation
              showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  message: Text('All data has been deleted'),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}