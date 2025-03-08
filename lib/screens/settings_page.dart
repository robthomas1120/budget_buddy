import 'package:flutter/cupertino.dart';
import '../database/database_helper.dart';
import '../services/backup_service.dart';
 
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildListItem(
              context,
              CupertinoIcons.person_fill,
              'Profile',
              onTap: () {
                // Navigate to profile settings
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Coming Soon'),
                    content: Text('Profile settings coming soon'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildListItem(
              context,
              CupertinoIcons.tag_fill,
              'Categories',
              onTap: () {
                // Navigate to categories settings
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Coming Soon'),
                    content: Text('Category settings coming soon'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildListItem(
              context,
              CupertinoIcons.bell_fill,
              'Notifications',
              onTap: () {
                // Navigate to notification settings
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Coming Soon'),
                    content: Text('Notification settings coming soon'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildListItem(
              context,
              CupertinoIcons.arrow_clockwise,
              'Backup & Restore',
              onTap: () {
                _showBackupRestoreOptions(context);
              },
            ),
            _buildDivider(),
            _buildListItem(
              context,
              CupertinoIcons.square_arrow_right,
              'Export Data',
              onTap: () async {
                _showExportOptions(context);
              },
            ),
            _buildDivider(),
            _buildListItem(
              context,
              CupertinoIcons.delete,
              'Clear All Data',
              textColor: CupertinoColors.destructiveRed,
              onTap: () {
                _showClearDataDialog(context);
              },
            ),
            _buildDivider(),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Budget Buddy v1.0.0',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? CupertinoColors.activeBlue, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: textColor ?? CupertinoColors.black,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(left: 56),
      height: 0.5,
      color: CupertinoColors.separator,
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