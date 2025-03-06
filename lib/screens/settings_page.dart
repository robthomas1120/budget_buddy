import 'package:flutter/material.dart';
import '../database/database_helper.dart';

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
              // Navigate to backup settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Backup & Restore coming soon')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Export Data'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Show export options
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export functionality coming soon')),
              );
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
              'Finance Tracker v1.0.0',
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
}