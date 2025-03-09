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
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  } 
}