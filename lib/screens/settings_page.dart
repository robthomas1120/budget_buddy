import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../services/backup_service.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Define default text style for the page
    final defaultTextStyle = TextStyle(
      color: themeData.textColor,
      fontFamily: '.SF Pro Text',
      fontSize: 17,
    );
    
    return DefaultTextStyle(
      style: defaultTextStyle,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Settings'),
          backgroundColor: themeData.cardColor,
        ),
        backgroundColor: themeData.backgroundColor,
        child: SafeArea(
          child: ListView(
            children: [
              _buildListItem(
                context,
                CupertinoIcons.person_fill,
                'Profile',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  // Navigate to profile settings
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => _buildAlertDialog(
                      'Coming Soon',
                      'Profile settings coming soon',
                      context,
                    ),
                  );
                },
              ),
              _buildDivider(context, themeData),
              
              // Theme selection section
              _buildListItem(
                context,
                CupertinoIcons.paintbrush_fill,
                'Theme',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  _showThemeOptions(context, themeProvider);
                },
              ),
              _buildDivider(context, themeData),
              
              _buildListItem(
                context,
                CupertinoIcons.tag_fill,
                'Categories',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  // Navigate to categories settings
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => _buildAlertDialog(
                      'Coming Soon',
                      'Category settings coming soon',
                      context,
                    ),
                  );
                },
              ),
              _buildDivider(context, themeData),
              _buildListItem(
                context,
                CupertinoIcons.bell_fill,
                'Notifications',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  // Navigate to notification settings
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => _buildAlertDialog(
                      'Coming Soon',
                      'Notification settings coming soon',
                      context,
                    ),
                  );
                },
              ),
              _buildDivider(context, themeData),
              _buildListItem(
                context,
                CupertinoIcons.arrow_clockwise,
                'Backup & Restore',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  _showBackupRestoreOptions(context, themeData);
                },
              ),
              _buildDivider(context, themeData),
              _buildListItem(
                context,
                CupertinoIcons.square_arrow_right,
                'Export Data',
                color: themeData.secondaryColor,
                textColor: themeData.textColor,
                backgroundColor: themeData.cardColor,
                onTap: () async {
                  _showExportOptions(context, themeData);
                },
              ),
              _buildDivider(context, themeData),
              _buildListItem(
                context,
                CupertinoIcons.delete,
                'Clear All Data',
                textColor: CupertinoColors.destructiveRed,
                color: CupertinoColors.destructiveRed,
                backgroundColor: themeData.cardColor,
                onTap: () {
                  _showClearDataDialog(context, themeData);
                },
              ),
              _buildDivider(context, themeData),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Budget Buddy v1.0.0',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  CupertinoAlertDialog _buildAlertDialog(String title, String content, BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return DefaultTextStyle(
      style: TextStyle(color: textColor),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, AppThemeData themeData) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 0.5,
      color: CupertinoColors.separator,
    );
  }

  void _showThemeOptions(BuildContext context, ThemeProvider themeProvider) {
    final themeData = themeProvider.currentThemeData;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontFamily: '.SF Pro Text',
        ),
        child: CupertinoActionSheet(
          title: const Text('Choose Theme'),
          message: const Text('Select your preferred app theme'),
          actions: AppTheme.values.map((theme) {
            final isSelected = themeProvider.currentTheme == theme;
            return CupertinoActionSheetAction(
              onPressed: () {
                themeProvider.setTheme(theme);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(themeProvider.getThemeName(theme)),
                  if (isSelected) Icon(CupertinoIcons.check_mark, color: themeData.primaryColor),
                ],
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ),
    );
  }

  void _showBackupRestoreOptions(BuildContext context, AppThemeData themeData) {
    showCupertinoModalPopup(
      context: context,
      builder: (bottomSheetContext) => DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontFamily: '.SF Pro Text',
        ),
        child: CupertinoActionSheet(
          title: const Text('Backup & Restore'),
          message: const Text('Choose an option'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Create Backup'),
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
                        children: const [
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
                    builder: (context) => DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontFamily: '.SF Pro Text',
                      ),
                      child: CupertinoActionSheet(
                        message: const Text('Backup created and ready to share'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Restore from Backup'),
              onPressed: () async {
                Navigator.pop(bottomSheetContext);
                
                // Confirm restore
                bool shouldRestore = await showCupertinoDialog<bool>(
                  context: context,
                  builder: (alertContext) => CupertinoAlertDialog(
                    title: const Text('Restore from Backup'),
                    content: const Text(
                      'This will replace all your current data with the data from the backup file. Continue?'
                    ),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(alertContext, false),
                      ),
                      CupertinoDialogAction(
                        child: const Text('Restore'),
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
                        children: const [
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
                    builder: (context) => DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontFamily: '.SF Pro Text',
                      ),
                      child: CupertinoActionSheet(
                        message: const Text('Data restored successfully'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(bottomSheetContext),
            child: const Text('Cancel'),
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, AppThemeData themeData) {
    showCupertinoModalPopup(
      context: context,
      builder: (bottomSheetContext) => DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontFamily: '.SF Pro Text',
        ),
        child: CupertinoActionSheet(
          title: const Text('Export Data'),
          message: const Text('Choose a format'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Export as CSV'),
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
                        children: const [
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
                    builder: (context) => DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontFamily: '.SF Pro Text',
                      ),
                      child: CupertinoActionSheet(
                        message: const Text('Data exported and ready to share'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(bottomSheetContext),
            child: const Text('Cancel'),
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppThemeData themeData) {
    showCupertinoDialog(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: TextStyle(color: themeData.textColor),
        child: CupertinoAlertDialog(
          title: const Text(
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
              color: themeData.textColor.withOpacity(0.8),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () async {
                await DatabaseHelper.instance.deleteAllTransactions();
                Navigator.of(context).pop();
                
                // Show iOS-style confirmation
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => DefaultTextStyle(
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontFamily: '.SF Pro Text',
                    ),
                    child: CupertinoActionSheet(
                      message: const Text('All data has been deleted'),
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}