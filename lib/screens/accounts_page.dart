// lib/screens/accounts_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';
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
      print('DEBUG: [AccountsPage] Starting to load accounts');
    final accounts = await DatabaseHelper.instance.getAllAccounts();
      print('DEBUG: [AccountsPage] Loaded ${accounts.length} accounts');

    for (var account in accounts) {
    print('DEBUG: [AccountsPage] Account ${account.id}: ${account.name} - Type: ${account.type}, Balance: ${account.balance}');
  }

    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
              print('DEBUG: [AccountsPage] State updated with account data');

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('My Accounts', style: TextStyle(color: themeData.textColor)),
        backgroundColor: themeData.cardColor,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _accounts.length >= 2 
              ? GestureDetector(
                  onTap: _showTransferDialog,
                  child: Icon(CupertinoIcons.arrow_right_arrow_left, color: themeData.primaryColor),
                )
              : SizedBox.shrink(),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => _showAddAccountDialog(),
              child: Icon(CupertinoIcons.add, color: themeData.primaryColor),
            ),
          ],
        ),
      ),
      child: _isLoading 
        ? Center(child: CupertinoActivityIndicator())
        : _accounts.isEmpty 
          ? _buildEmptyState(themeData)
          : _buildAccountsList(themeData),
    );
  }

  Widget _buildEmptyState(AppThemeData themeData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.creditcard,
            size: 80,
            color: themeData.brightness == Brightness.dark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey4,
          ),
          SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add an account to track your money',
            style: TextStyle(
              color: themeData.textColor.withOpacity(0.7),
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

  Widget _buildAccountsList(AppThemeData themeData) {
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
                    color: themeData.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: themeData.brightness == Brightness.dark 
                            ? Colors.black.withOpacity(0.2)
                            : CupertinoColors.systemGrey5,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showAccountDetails(account, themeData),
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
                                  color: themeData.textColor,
                                ),
                              ),
                              Text(
                                account.type,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeData.brightness == Brightness.dark
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey,
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
                                  color: account.balance >= 0 ? themeData.incomeColor : themeData.expenseColor,
                                ),
                              ),
                              Text(
                                'Current Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeData.brightness == Brightness.dark
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey,
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

void _showAccountDetails(Account account, AppThemeData themeData) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => DefaultTextStyle(
      style: TextStyle(
        color: themeData.textColor,
        fontFamily: '.SF Pro Text',
        fontSize: 16,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: themeData.cardColor,
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
                  color: themeData.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Type: ${account.type}',
                style: TextStyle(
                  fontSize: 16,
                  color: themeData.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Balance: ₱${account.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: account.balance >= 0 ? themeData.incomeColor : themeData.expenseColor,
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
                      _showEditAccountDialog(account, themeData);
                    },
                    child: Text('Edit', style: TextStyle(color: themeData.secondaryColor)),
                    padding: EdgeInsets.zero,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteAccount(account, themeData);
                    },
                    child: Text('Delete', style: TextStyle(color: themeData.expenseColor)),
                    padding: EdgeInsets.zero,
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close', style: TextStyle(color: themeData.textColor)),
                    padding: EdgeInsets.zero,
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

  void _showTransferDialog() {
      print('DEBUG: [AccountsPage] Showing transfer dialog');

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final themeData = themeProvider.currentThemeData;
    
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
    print('DEBUG: [AccountsPage] Opening add account dialog');

  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final themeData = themeProvider.currentThemeData;
  
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'Bank';
  final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
  
  showCupertinoModalPopup(
    context: context,
    builder: (context) => DefaultTextStyle(
      style: TextStyle(
        color: themeData.textColor,
        fontFamily: '.SF Pro Text',
        fontSize: 16,
      ),
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeData.cardColor,
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
                    color: themeData.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Account Name',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: themeData.textColor,
                  ),
                ),
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Account Name',
                  padding: EdgeInsets.all(12),
                  style: TextStyle(color: themeData.textColor),
                  placeholderStyle: TextStyle(color: themeData.brightness == Brightness.dark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey),
                  decoration: BoxDecoration(
                    color: themeData.brightness == Brightness.dark
                        ? Color(0xFF2C2C2E) // Darker gray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeData.brightness == Brightness.dark
                        ? CupertinoColors.systemGrey.withOpacity(0.5)
                        : CupertinoColors.systemGrey5),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Account Type',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: themeData.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: themeData.brightness == Brightness.dark
                        ? Color(0xFF2C2C2E) // Darker gray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeData.brightness == Brightness.dark
                        ? CupertinoColors.systemGrey.withOpacity(0.5)
                        : CupertinoColors.systemGrey5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: _selectedType,
                    children: {
                      for (String type in _types)
                        type: Text(
                          type,
                          style: TextStyle(
                            color: themeData.textColor,
                          ),
                        ),
                    },
                    backgroundColor: themeData.brightness == Brightness.dark
                        ? Color(0xFF1C1C1E) // Dark background
                        : CupertinoColors.systemGrey6,
                    thumbColor: themeData.brightness == Brightness.dark
                        ? Color(0xFF3A3A3C) // Slightly lighter than background
                        : CupertinoColors.white,
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Initial Balance (₱)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: themeData.textColor,
                  ),
                ),
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: _balanceController,
                  placeholder: 'Initial Balance (₱)',
                  padding: EdgeInsets.all(12),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: themeData.textColor),
                  placeholderStyle: TextStyle(color: themeData.brightness == Brightness.dark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey),
                  decoration: BoxDecoration(
                    color: themeData.brightness == Brightness.dark
                        ? Color(0xFF2C2C2E) // Darker gray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeData.brightness == Brightness.dark
                        ? CupertinoColors.systemGrey.withOpacity(0.5)
                        : CupertinoColors.systemGrey5),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: themeData.secondaryColor)),
                    ),
                    CupertinoButton.filled(
                      onPressed: () async {
                            print('DEBUG: [AccountsPage] Validating new account data');
                        if (_nameController.text.trim().isEmpty) {
                          _showError('Please enter an account name', themeData);
                          return;
                        }

                        if (_balanceController.text.trim().isEmpty) {
                          _showError('Please enter an initial balance', themeData);
                          return;
                        }

                        final balance = double.tryParse(_balanceController.text);
                        if (balance == null) {
                          _showError('Please enter a valid balance', themeData);
                          return;
                        }
    print('DEBUG: [AccountsPage] Creating new account: Name=${_nameController.text.trim()}, Type=${_selectedType}, Balance=${_balanceController.text}');

                        final account = Account(
                          name: _nameController.text.trim(),
                          type: _selectedType,
                          balance: balance,
                        );
    print('DEBUG: [AccountsPage] Inserting account into database');

                        await DatabaseHelper.instance.insertAccount(account);
          print('DEBUG: [AccountsPage] Account inserted successfully');
                  
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
    ),
  );
}

  void _showEditAccountDialog(Account account, AppThemeData themeData) {
      print('DEBUG: [AccountsPage] Opening edit dialog for account ${account.id}: ${account.name}');

    final _nameController = TextEditingController(text: account.name);
    final _balanceController = TextEditingController(text: account.balance.toString());
    String _selectedType = account.type;
    final _types = ['Bank', 'E-Wallet', 'Cash', 'Other'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: TextStyle(
          color: themeData.textColor,
          fontFamily: '.SF Pro Text',
          fontSize: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeData.cardColor,
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
                      color: themeData.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Account Name',
                    padding: EdgeInsets.all(12),
                    style: TextStyle(color: themeData.textColor),
                    placeholderStyle: TextStyle(color: themeData.brightness == Brightness.dark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey),
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? Color(0xFF2C2C2E) // Darker gray
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey.withOpacity(0.5)
                          : CupertinoColors.systemGrey5),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? Color(0xFF2C2C2E) // Darker gray
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey.withOpacity(0.5)
                          : CupertinoColors.systemGrey5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeData.brightness == Brightness.dark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(height: 4),
                        CupertinoSlidingSegmentedControl<String>(
                          groupValue: _types.contains(_selectedType) ? _selectedType : 'Other',
                          children: {
                            for (String type in _types)
                              type: Text(
                                type,
                                style: TextStyle(
                                  color: themeData.textColor,
                                ),
                              ),
                          },
                          backgroundColor: themeData.brightness == Brightness.dark
                              ? Color(0xFF1C1C1E) // Dark background
                              : CupertinoColors.systemGrey6,
                          thumbColor: themeData.brightness == Brightness.dark
                              ? Color(0xFF3A3A3C) // Slightly lighter than background
                              : CupertinoColors.white,
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
                        style: TextStyle(color: themeData.textColor),
                        placeholderStyle: TextStyle(color: themeData.brightness == Brightness.dark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey),
                        decoration: BoxDecoration(
                          color: themeData.brightness == Brightness.dark
                              ? Color(0xFF2C2C2E) // Darker gray
                              : CupertinoColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeData.brightness == Brightness.dark
                              ? CupertinoColors.systemGrey.withOpacity(0.5)
                              : CupertinoColors.systemGrey5),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Editing balance directly might not match transaction history',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeData.textColor.withOpacity(0.6),
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
                        child: Text('Cancel', style: TextStyle(color: themeData.secondaryColor)),
                      ),
                      CupertinoButton.filled(
                        onPressed: () async {
                          if (_nameController.text.trim().isEmpty) {
                            _showError('Please enter an account name', themeData);
                            return;
                          }

                          if (_balanceController.text.trim().isEmpty) {
                            _showError('Please enter a balance', themeData);
                            return;
                          }

                          final balance = double.tryParse(_balanceController.text);
                          if (balance == null) {
                            _showError('Please enter a valid balance', themeData);
                            return;
                          }
print('DEBUG: [AccountsPage] Updating account ${account.id}');
    print('DEBUG: [AccountsPage] New values - Name: ${_nameController.text.trim()}, Type: ${_selectedType}, Balance: ${_balanceController.text}');

                          final updatedAccount = account.copyWith(
                            name: _nameController.text.trim(),
                            type: _selectedType,
                            balance: balance,
                          );

                          await DatabaseHelper.instance.updateAccount(updatedAccount);
                            print('DEBUG: [AccountsPage] Account updated successfully');

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
      ),
    );
  }

  void _confirmDeleteAccount(Account account, AppThemeData themeData) {
      print('DEBUG: [AccountsPage] Showing delete confirmation for account ${account.id}: ${account.name}');

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
                  print('DEBUG: [AccountsPage] Validating edited account data');

              try {
                      print('DEBUG: [AccountsPage] Attempting to delete account ${account.id}');

                await DatabaseHelper.instance.deleteAccount(account.id!);
                      print('DEBUG: [AccountsPage] Account deleted successfully');

                Navigator.pop(context);
                _loadAccounts();
              } catch (e) {
                      print('DEBUG: [AccountsPage] Error deleting account: $e');

                Navigator.pop(context);
                _showError('Cannot delete account with linked transactions', themeData);
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showError(String message, AppThemeData themeData) {
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