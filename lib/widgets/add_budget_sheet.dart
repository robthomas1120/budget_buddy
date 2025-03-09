// lib/widgets/add_budget_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';

class AddBudgetSheet extends StatefulWidget {
  final VoidCallback onBudgetAdded;

  const AddBudgetSheet({
    Key? key,
    required this.onBudgetAdded,
  }) : super(key: key);

  @override
  _AddBudgetSheetState createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedPeriod = 'monthly';
  List<Account> _accounts = [];
  List<int> _selectedAccountIds = [];
  bool _isLoading = true;
  
  final List<String> _categories = [
    'Food', 'Transportation', 'Entertainment', 'Housing', 
    'Shopping', 'Utilities', 'Healthcare', 'Education', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    
    final accounts = await DatabaseHelper.instance.getAllAccounts();
    
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  Future<void> _createBudget(
    String category,
    String amountStr,
    String period,
    List<int> accountIds,
  ) async {
    // Validate inputs
    if (amountStr.isEmpty) {
      _showError('Please enter a budget amount');
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount greater than zero');
      return;
    }

    // Calculate start and end dates
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (period == 'weekly') {
      // Start from today, end 6 days later (7 days total)
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate.add(Duration(days: 6));
    } else { // monthly
      // Start from first day of current month, end on last day
      startDate = DateTime(now.year, now.month, 1);
      // Go to first day of next month, then subtract one day to get last day of current month
      endDate = DateTime(now.year, now.month + 1, 0);
    }

    // Create budget object
    final budget = Budget(
      category: category,
      amount: amount,
      period: period,
      startDate: startDate,
      endDate: endDate,
      spent: 0.0,
      accountIds: accountIds.isEmpty ? null : accountIds,
    );

    // Save to database
    await DatabaseHelper.instance.insertBudget(budget);
    
    // Notify caller and close sheet
    Navigator.pop(context);
    widget.onBudgetAdded();
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
  
  void _showCategoryPicker(BuildContext context, AppThemeData themeData) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: themeData.cardColor,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: themeData.brightness == Brightness.dark 
                    ? Color(0xFF1C1C1E) 
                    : CupertinoColors.systemGrey6,
                  border: Border(
                    bottom: BorderSide(
                      color: themeData.brightness == Brightness.dark
                        ? Colors.black
                        : CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: themeData.cardColor,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: _categories.indexOf(_selectedCategory),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                  },
                  children: _categories.map((String category) {
                    return Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: themeData.textColor,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(themeData),
                    SizedBox(height: 16),
                    _buildCategorySelector(themeData),
                    SizedBox(height: 16),
                    _buildAmountField(themeData),
                    SizedBox(height: 16),
                    _buildPeriodSelector(themeData),
                    SizedBox(height: 16),
                    _buildAccountSelector(themeData),
                    SizedBox(height: 24),
                    _buildSubmitButton(themeData),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData themeData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Create Budget',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeData.textColor,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.xmark, color: themeData.brightness == Brightness.dark 
              ? CupertinoColors.systemGrey : CupertinoColors.systemGrey),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(AppThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: GestureDetector(
            onTap: () {
              _showCategoryPicker(context, themeData);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    color: themeData.textColor,
                    fontSize: 16,
                  ),
                ),
                Icon(CupertinoIcons.chevron_down, size: 16, color: themeData.textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(AppThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Amount:',
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
      ],
    );
  }

  Widget _buildPeriodSelector(AppThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Period:',
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
                ? CupertinoColors.systemGrey6.darkColor
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: _selectedPeriod,
            children: {
              'weekly': Text('Weekly', style: TextStyle(color: themeData.textColor)),
              'monthly': Text('Monthly', style: TextStyle(color: themeData.textColor)),
            },
            onValueChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedPeriod = value);
              }
            },
            backgroundColor: themeData.brightness == Brightness.dark 
                ? Color(0xFF1C1C1E) // Dark background
                : CupertinoColors.systemGrey6,
            thumbColor: themeData.brightness == Brightness.dark 
                ? Color(0xFF3A3A3C) // Slightly lighter than background
                : CupertinoColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(AppThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Include Accounts (optional):',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: themeData.textColor,
          ),
        ),
        Text(
          'Leave empty to include all accounts',
          style: TextStyle(
            fontSize: 12,
            color: themeData.textColor.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 8),
        if (_accounts.isEmpty)
          Text(
            'No accounts found',
            style: TextStyle(
              fontSize: 14,
              color: themeData.textColor.withOpacity(0.7),
            ),
          )
        else
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                final isSelected = _selectedAccountIds.contains(account.id);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAccountIds.remove(account.id);
                      } else if (account.id != null) {
                        _selectedAccountIds.add(account.id!);
                      }
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? themeData.primaryColor.withOpacity(0.1)
                          : themeData.brightness == Brightness.dark
                              ? CupertinoColors.systemGrey6.darkColor
                              : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? themeData.primaryColor
                            : themeData.brightness == Brightness.dark
                                ? CupertinoColors.systemGrey.withOpacity(0.3)
                                : CupertinoColors.systemGrey4,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getAccountIcon(account.type),
                          color: isSelected
                              ? themeData.primaryColor
                              : _getAccountColor(account.type),
                          size: 24,
                        ),
                        SizedBox(height: 8),
                        Text(
                          account.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeData.textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(AppThemeData themeData) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(8),
        color: themeData.primaryColor,
        onPressed: () => _createBudget(
          _selectedCategory,
          _amountController.text,
          _selectedPeriod,
          _selectedAccountIds,
        ),
        child: Text(
          'Create Budget',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
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
}