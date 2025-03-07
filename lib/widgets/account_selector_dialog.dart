// widgets/account_selector_dialog.dart

import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountSelectorDialog extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onAccountSelected;

  const AccountSelectorDialog({
    Key? key,
    required this.accounts,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getAccountColor(account.type),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(account.name),
                  subtitle: Text(account.type),
                  trailing: Text(
                    '₱${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onAccountSelected(account);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'cash':
        return Icons.money;
      default:
        return Icons.credit_card;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Colors.blue;
      case 'e-wallet':
      case 'ewallet':
        return Colors.purple;
      case 'cash':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}