// lib/widgets/add_transaction_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  final String transactionType;
  final Function onTransactionAdded;
  final Transaction? transaction;

  const AddTransactionSheet({
    Key? key,
    this.transactionType = '',
    required this.onTransactionAdded,
    this.transaction,
  }) : super(key: key);

  @override
  _AddTransactionSheetState createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = '';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;
  List<Account> _accounts = [];
  bool _isLoadingAccounts = true;
  Account? _selectedAccount;
  bool _isEditing = false;

  List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gift',
    'Other',
  ];

  List<String> _expenseCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Housing',
    'Shopping',
    'Utilities',
    'Healthcare',
    'Education',
    'Other',
  ];

  List<String> _transferCategories = [
    'Transfer',
  ];

  void _processTransactionForSavingsGoals(Transaction transaction) async {
    if (transaction.type == 'income') {
      print('DEBUG: [AddTransactionSheet] Checking if transaction contributes to savings goals');

      // Get all savings goals
      final savingsGoals = await DatabaseHelper.instance.getAllSavingsGoals();

      // Check if transaction title matches any goal name
      for (var goal in savingsGoals) {
        if (transaction.title.toLowerCase().contains(goal.name.toLowerCase())) {
          print('DEBUG: [AddTransactionSheet] Transaction matches savings goal: ${goal.name}');

          // Update the goal with the transaction amount
          final updatedGoal = goal.copyWith(
            currentAmount: goal.currentAmount + transaction.amount,
          );

          await DatabaseHelper.instance.updateSavingsGoal(updatedGoal);
          print('DEBUG: [AddTransactionSheet] Updated savings goal ${goal.name} with amount ${transaction.amount}');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Set default transaction type
    _selectedType = widget.transactionType.isNotEmpty
        ? widget.transactionType
        : 'expense';

    // Set default category based on type
    _selectedCategory = _selectedType == 'income'
        ? _incomeCategories.first
        : _selectedType == 'transfer'
            ? _transferCategories.first
            : _expenseCategories.first;

    // Check if we're editing an existing transaction
    if (widget.transaction != null) {
      _isEditing = true;
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes ?? '';
      _selectedType = widget.transaction!.type;

      // First set the type, then set the appropriate category list
      if (_selectedType == 'income') {
        // If the category is not in the income categories, default to the first one
        _selectedCategory = _incomeCategories.contains(widget.transaction!.category)
            ? widget.transaction!.category
            : _incomeCategories.first;
      } else if (_selectedType == 'transfer') {
        // For transfer transactions, always use the Transfer category
        _selectedCategory = 'Transfer';
      } else {
        // For expense transactions
        _selectedCategory = _expenseCategories.contains(widget.transaction!.category)
            ? widget.transaction!.category
            : _expenseCategories.first;
      }

      _selectedDate = widget.transaction!.date;
      _selectedAccountId = widget.transaction!.accountId;
    }

    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });

    print('DEBUG: Loading accounts from database');
    final accounts = await DatabaseHelper.instance.getAllAccounts();
    print('DEBUG: Loaded ${accounts.length} accounts from database');

    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoadingAccounts = false;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts[0].id;
          _selectedAccount = accounts[0];
          print('DEBUG: Selected first account: ${_selectedAccount?.name}, ID: $_selectedAccountId');
        } else {
          print('DEBUG: No accounts found');
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, AppThemeData themeData) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: themeData.cardColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel', style: TextStyle(color: themeData.secondaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done', style: TextStyle(color: themeData.secondaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  maximumDate: DateTime.now().add(Duration(days: 1)),
                  minimumDate: DateTime(2020),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      print('DEBUG: Date selected: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    print('DEBUG: Showing error: $message');
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

  void _saveTransaction() async {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_selectedAccountId == null) {
      _showError('Please select an account');
      return;
    }

    try {
      // For editing transactions, we'll use the updateTransaction method which already has transaction handling
      if (_isEditing && widget.transaction != null) {
        // Update existing transaction
        final updatedTransaction = Transaction(
          id: widget.transaction!.id,
          title: _titleController.text,
          amount: amount,
          type: _selectedType,
          category: _selectedCategory,
          date: _selectedDate,
          accountId: _selectedAccountId,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await DatabaseHelper.instance.updateTransaction(updatedTransaction);
        print('Transaction updated: ${updatedTransaction.title}');
      } else {
        // Create new transaction - this already handles all account updates within a transaction
        final newTransaction = Transaction(
          title: _titleController.text,
          amount: amount,
          type: _selectedType,
          category: _selectedCategory,
          date: _selectedDate,
          accountId: _selectedAccountId,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await DatabaseHelper.instance.insertTransaction(newTransaction);
        print('Transaction added: ${newTransaction.title}');
      }

      Navigator.pop(context);
      widget.onTransactionAdded();
    } catch (e) {
      _showError('Error saving transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;

    // Make sure we have the correct category list based on transaction type
    List<String> categories = [];
    if (_selectedType == 'income') {
      categories = _incomeCategories;
      // If the selected category is not in income categories, reset it
      if (!_incomeCategories.contains(_selectedCategory)) {
        _selectedCategory = _incomeCategories.first;
      }
    } else if (_selectedType == 'transfer') {
      categories = _transferCategories;
      // For transfer type, always use 'Transfer' category
      _selectedCategory = 'Transfer';
    } else {
      categories = _expenseCategories;
      // If the selected category is not in expense categories, reset it
      if (!_expenseCategories.contains(_selectedCategory)) {
        _selectedCategory = _expenseCategories.first;
      }
    }

    final typeColor = _selectedType == 'income'
        ? themeData.incomeColor
        : _selectedType == 'transfer'
            ? CupertinoColors.systemBlue
            : themeData.expenseColor;

    // Wrap with Material widget to make the dropdown work
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: TextStyle(
          color: themeData.textColor,
          fontFamily: '.SF Pro Text',
          fontSize: 14,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeData.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Edit Transaction' : 'Add Transaction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeData.textColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(CupertinoIcons.xmark, color: CupertinoColors.systemGrey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Transaction type toggle
                  if (widget.transactionType.isEmpty) ...[
                    Text(
                      'Transaction Type:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: _selectedType,
                      children: {
                        'income': Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: _selectedType == 'income' ? CupertinoColors.white : themeData.textColor,
                            ),
                          ),
                        ),
                        'expense': Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: _selectedType == 'expense' ? CupertinoColors.white : themeData.textColor,
                            ),
                          ),
                        ),
                      },
                      thumbColor: _selectedType == 'income'
                          ? themeData.incomeColor
                          : themeData.expenseColor,
                      backgroundColor: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _selectedCategory = value == 'income'
                                ? _incomeCategories[0]
                                : _expenseCategories[0];
                            print('DEBUG: Transaction type changed to $_selectedType, category set to $_selectedCategory');
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                  ],

                  // Account selection
                  if (_isLoadingAccounts)
                    Center(child: CupertinoActivityIndicator())
                  else if (_accounts.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No accounts found',
                          style: TextStyle(color: themeData.expenseColor),
                        ),
                        SizedBox(height: 8),
                        CupertinoButton.filled(
                          onPressed: () {
                            // Navigate to AccountsPage or show a dialog
                            Navigator.pop(context);
                            _showError('Please add an account first');
                          },
                          child: Text('Add Account'),
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: themeData.textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeData.brightness == Brightness.dark
                                ? CupertinoColors.systemGrey6.darkColor
                                : CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Account>(
                              value: _selectedAccount,
                              isExpanded: true,
                              dropdownColor: themeData.cardColor,
                              style: TextStyle(
                                color: themeData.textColor,
                                fontSize: 16,
                              ),
                              icon: Icon(CupertinoIcons.chevron_down, size: 16, color: themeData.textColor),
                              items: _accounts.map((Account account) {
                                return DropdownMenuItem<Account>(
                                  value: account,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getAccountIcon(account.type),
                                        color: _getAccountColor(account.type),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${account.name} (₱${account.balance.toStringAsFixed(2)})',
                                        style: TextStyle(color: themeData.textColor),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (Account? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedAccount = newValue;
                                    _selectedAccountId = newValue.id;
                                    print('DEBUG: Selected account changed to: ${newValue.name}, ID: ${newValue.id}');
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),

                  // Amount field
                  Text(
                    'Amount:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: themeData.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _amountController,
                    placeholder: '0.00',
                    prefix: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text('₱', style: TextStyle(color: themeData.textColor)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: themeData.textColor),
                  ),
                  SizedBox(height: 16),

                  // Title field
                  Text(
                    'Title:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: themeData.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Enter title',
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: TextStyle(color: themeData.textColor),
                    placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  SizedBox(height: 16),

                  // Category dropdown
                  Text(
                    'Category:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: themeData.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(CupertinoIcons.chevron_down, size: 16, color: themeData.textColor),
                        style: TextStyle(
                          color: themeData.textColor,
                          fontSize: 16,
                        ),
                        dropdownColor: themeData.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: themeData.textColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              print('DEBUG: Selected category changed to: $_selectedCategory');
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Date picker
                  Text(
                    'Date:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: themeData.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context, themeData),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: themeData.brightness == Brightness.dark
                            ? CupertinoColors.systemGrey6.darkColor
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: themeData.textColor,
                            ),
                          ),
                          Icon(CupertinoIcons.calendar, color: CupertinoColors.systemGrey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Notes field
                  Text(
                    'Notes (optional):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: themeData.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: 'Add notes about this transaction',
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    maxLines: 3,
                    style: TextStyle(color: themeData.textColor),
                    placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      borderRadius: BorderRadius.circular(8),
                      color: typeColor,
                      onPressed: _saveTransaction,
                      child: Text(_isEditing ? 'Update' : 'Add'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}