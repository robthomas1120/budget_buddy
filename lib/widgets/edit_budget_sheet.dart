// lib/widgets/edit_budget_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';

class EditBudgetSheet extends StatefulWidget {
  final Budget budget;
  final VoidCallback onBudgetUpdated;

  const EditBudgetSheet({
    Key? key,
    required this.budget,
    required this.onBudgetUpdated,
  }) : super(key: key);

  @override
  _EditBudgetSheetState createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<EditBudgetSheet> {
  late TextEditingController _amountController;
  late String _selectedCategory;
  List<Account> _accounts = [];
  late List<int> _selectedAccountIds;
  bool _isLoading = true;
  
  final List<String> _categories = [
    'Food', 'Transportation', 'Entertainment', 'Housing', 
    'Shopping', 'Utilities', 'Healthcare', 'Education', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.budget.amount.toString());
    _selectedCategory = widget.budget.category;
    _selectedAccountIds = widget.budget.accountIds ?? [];
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

  Future<void> _updateBudget() async {
    // Validate inputs
    if (_amountController.text.isEmpty) {
      _showError('Please enter a budget amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount greater than zero');
      return;
    }

    // Create updated budget object
    final updatedBudget = widget.budget.copyWith(
      category: _selectedCategory,
      amount: amount,
      accountIds: _selectedAccountIds.isEmpty ? null : _selectedAccountIds,
    );

    // Save to database
    await DatabaseHelper.instance.updateBudget(updatedBudget);
    
    // Notify caller and close sheet
    Navigator.pop(context);
    widget.onBudgetUpdated();
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
                    _buildPeriodInfo(themeData),
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
          'Edit Budget',
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
          child: DefaultTextStyle(
            style: TextStyle(color: themeData.textColor),
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
                items: _categories.map((String category) {
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
                    });
                  }
                },
              ),
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

  Widget _buildPeriodInfo(AppThemeData themeData) {
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
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeData.brightness == Brightness.dark 
                ? CupertinoColors.systemGrey6.darkColor
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.budget.period == 'weekly' ? 'Weekly Budget' : 'Monthly Budget',
                style: TextStyle(
                  color: themeData.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Period cannot be changed',
                style: TextStyle(
                  color: themeData.textColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
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
        onPressed: _updateBudget,
        child: Text(
          'Save Changes',
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