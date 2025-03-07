// widgets/create_account_dialog.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/account.dart';

class CreateAccountDialog extends StatefulWidget {
  final Function onAccountCreated;

  const CreateAccountDialog({
    Key? key,
    required this.onAccountCreated,
  }) : super(key: key);

  @override
  _CreateAccountDialogState createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'Bank';
  final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
  
  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              decoration: InputDecoration(
                labelText: 'Initial Balance (₱)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) {
                      _showError('Please enter an account name');
                      return;
                    }

                    if (_balanceController.text.trim().isEmpty) {
                      _showError('Please enter an initial balance');
                      return;
                    }

                    final balance = double.tryParse(_balanceController.text);
                    if (balance == null) {
                      _showError('Please enter a valid balance');
                      return;
                    }

                    final account = Account(
                      name: _nameController.text.trim(),
                      type: _selectedType,
                      balance: balance,
                    );

                    await DatabaseHelper.instance.insertAccount(account);
                    Navigator.pop(context);
                    widget.onAccountCreated();
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}