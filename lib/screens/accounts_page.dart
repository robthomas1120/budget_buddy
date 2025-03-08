import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../widgets/transfer_dialog.dart';

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
    
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('My Accounts'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _accounts.length >= 2 
              ? GestureDetector(
                  onTap: _showTransferDialog,
                  child: Icon(CupertinoIcons.arrow_right_arrow_left),
                )
              : SizedBox.shrink(),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => _showAddAccountDialog(),
              child: Icon(CupertinoIcons.add),
            ),
          ],
        ),
      ),
      child: _isLoading 
        ? Center(child: CupertinoActivityIndicator())
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
            CupertinoIcons.creditcard,
            size: 80,
            color: CupertinoColors.systemGrey4,
          ),
          SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add an account to track your money',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 24),
          CupertinoButton.filled(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: () => _showAddAccountDialog(),
            child: Text('Add Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _loadAccounts,
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final account = _accounts[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey5,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showAccountDetails(account),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getAccountColor(account.type),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getAccountIcon(account.type),
                              color: CupertinoColors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              Text(
                                account.type,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱${account.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: account.balance >= 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                                ),
                              ),
                              Text(
                                'Current Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _accounts.length,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return CupertinoIcons.building_2_fill;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoIcons.creditcard_fill;
      case 'cash':
        return CupertinoIcons.money_dollar_circle_fill;
      default:
        return CupertinoIcons.creditcard_fill;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return CupertinoColors.systemBlue;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoColors.systemPurple;
      case 'cash':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemIndigo;
    }
  }

  void _showAccountDetails(Account account) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                account.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Type: ${account.type}',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Balance: ₱${account.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: account.balance >= 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditAccountDialog(account);
                    },
                    child: Text('Edit', style: TextStyle(color: CupertinoColors.activeBlue)),
                    padding: EdgeInsets.zero,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteAccount(account);
                    },
                    child: Text('Delete', style: TextStyle(color: CupertinoColors.destructiveRed)),
                    padding: EdgeInsets.zero,
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransferDialog() {
    if (_accounts.length < 2) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Not Enough Accounts'),
          content: Text('You need at least 2 accounts to make a transfer'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => TransferDialog(
        accounts: _accounts,
        onTransferComplete: _loadAccounts,
      ),
    );
  }

  void _showAddAccountDialog() {
    final _nameController = TextEditingController();
    final _balanceController = TextEditingController();
    String _selectedType = 'Bank';
    final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Account Name',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey5),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(height: 4),
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedType,
                        children: {
                          for (String type in _types)
                            type: Text(type),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _balanceController,
                  placeholder: 'Initial Balance (₱)',
                  padding: EdgeInsets.all(12),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey5),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    CupertinoButton.filled(
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
                        _loadAccounts();
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditAccountDialog(Account account) {
    final _nameController = TextEditingController(text: account.name);
    final _balanceController = TextEditingController(text: account.balance.toString());
    String _selectedType = account.type;
    final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Account Name',
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey5),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.systemGrey5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(height: 4),
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: _types.contains(_selectedType) ? _selectedType : 'Other',
                        children: {
                          for (String type in _types)
                            type: Text(type),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: _balanceController,
                      placeholder: 'Balance (₱)',
                      padding: EdgeInsets.all(12),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CupertinoColors.systemGrey5),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Editing balance directly might not match transaction history',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    CupertinoButton.filled(
                      onPressed: () async {
                        if (_nameController.text.trim().isEmpty) {
                          _showError('Please enter an account name');
                          return;
                        }

                        if (_balanceController.text.trim().isEmpty) {
                          _showError('Please enter a balance');
                          return;
                        }

                        final balance = double.tryParse(_balanceController.text);
                        if (balance == null) {
                          _showError('Please enter a valid balance');
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(Account account) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Account?'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? This action cannot be undone.'
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteAccount(account.id!);
                Navigator.pop(context);
                _loadAccounts();
              } catch (e) {
                Navigator.pop(context);
                _showError('Cannot delete account with linked transactions');
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}