// screens/accounts_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    final accounts = await DatabaseHelper.instance.getAllAccounts();
    
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Accounts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(),
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _accounts.isEmpty 
            ? _buildEmptyState()
            : _buildAccountsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add an account to track your money',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _showAddAccountDialog(),
            child: Text('Add Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: _getAccountColor(account.type),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                account.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(account.type),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              onTap: () => _showAccountDetails(account),
            ),
          );
        },
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

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${account.type}'),
            SizedBox(height: 8),
            Text(
              'Balance: ₱${account.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditAccountDialog(account);
            },
            child: Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount(account);
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    final _nameController = TextEditingController();
    final _balanceController = TextEditingController();
    String _selectedType = 'Bank';
    final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an account name')),
                  );
                  return;
                }

                if (_balanceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an initial balance')),
                  );
                  return;
                }

                final balance = double.tryParse(_balanceController.text);
                if (balance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid balance')),
                  );
                  return;
                }

                final account = Account(
                  name: _nameController.text.trim(),
                  type: _selectedType,
                  balance: balance,
                );

                await DatabaseHelper.instance.insertAccount(account);
                Navigator.pop(context);
                _loadAccounts();
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAccountDialog(Account account) {
    final _nameController = TextEditingController(text: account.name);
    final _balanceController = TextEditingController(text: account.balance.toString());
    String _selectedType = account.type;
    final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  value: _types.contains(_selectedType) ? _selectedType : 'Other',
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
                    labelText: 'Balance (₱)',
                    border: OutlineInputBorder(),
                    helperText: 'Editing balance directly might not match transaction history',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an account name')),
                  );
                  return;
                }

                if (_balanceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a balance')),
                  );
                  return;
                }

                final balance = double.tryParse(_balanceController.text);
                if (balance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid balance')),
                  );
                  return;
                }

                final updatedAccount = account.copyWith(
                  name: _nameController.text.trim(),
                  type: _selectedType,
                  balance: balance,
                );

                await DatabaseHelper.instance.updateAccount(updatedAccount);
                Navigator.pop(context);
                _loadAccounts();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteAccount(account.id!);
                Navigator.pop(context);
                _loadAccounts();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot delete account with linked transactions'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}