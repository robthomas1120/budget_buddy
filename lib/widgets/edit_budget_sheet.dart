// lib/widgets/edit_budget_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late String _selectedCategory;
  late String _selectedPeriod;
  List<Account> _accounts = [];
  List<int> _selectedAccountIds = [];
  bool _isLoading = true;

  // Define your categories
  final List<String> _categories = [
    "Food", "Transportation", "Entertainment", "Utilities", 
    "Shopping", "Education", "Others"
  ];
  
  final List<String> _periods = ["weekly", "monthly"];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.budget.amount.toString());
    _selectedCategory = widget.budget.category;
    _selectedPeriod = widget.budget.period;
    _selectedAccountIds = widget.budget.accountIds ?? [];
    _loadAccounts();
    
    // Make sure the category from the budget is in our list
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
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
    if (!_formKey.currentState!.validate()) return;

    final updatedBudget = Budget(
      id: widget.budget.id,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      period: _selectedPeriod,
      spent: widget.budget.spent,
      startDate: widget.budget.startDate,
      endDate: widget.budget.endDate,
      accountIds: _selectedAccountIds.isEmpty ? null : _selectedAccountIds,
    );

    await DatabaseHelper.instance.updateBudget(updatedBudget);
    widget.onBudgetUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return Material(  // Add Material widget here
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: _isLoading 
            ? Center(child: CupertinoActivityIndicator()) 
            : _buildForm(themeData),
        ),
      ),
    );
  }

  Widget _buildForm(AppThemeData themeData) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                child: Icon(CupertinoIcons.xmark_circle, color: CupertinoColors.systemGrey),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Category Dropdown
          Text('Category', style: TextStyle(color: themeData.textColor)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          SizedBox(height: 16),
          
          // Amount Input
          Text('Amount', style: TextStyle(color: themeData.textColor)),
          SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              fillColor: themeData.brightness == Brightness.dark 
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixText: '₱ ',
              prefixStyle: TextStyle(color: themeData.textColor),
            ),
            style: TextStyle(color: themeData.textColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than zero';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          // Period Dropdown
          Text('Period', style: TextStyle(color: themeData.textColor)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: BoxDecoration(
              color: themeData.brightness == Brightness.dark 
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                icon: Icon(CupertinoIcons.chevron_down, size: 16, color: themeData.textColor),
                style: TextStyle(
                  color: themeData.textColor,
                  fontSize: 16,
                ),
                dropdownColor: themeData.cardColor,
                borderRadius: BorderRadius.circular(8),
                items: _periods.map((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(
                      period.capitalize(),
                      style: TextStyle(color: themeData.textColor),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Accounts Selection
          Text('Include Accounts', style: TextStyle(color: themeData.textColor)),
          SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: themeData.brightness == Brightness.dark 
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _accounts.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final account = _accounts[index];
                final isSelected = _selectedAccountIds.contains(account.id);
                
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Material( // Add Material widget here for inkwell
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAccountIds.remove(account.id);
                          } else {
                            _selectedAccountIds.add(account.id!);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              _getAccountIcon(account.type),
                              color: _getAccountColor(account.type),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                account.name,
                                style: TextStyle(color: themeData.textColor),
                              ),
                            ),
                            Icon(
                              isSelected 
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.circle,
                              color: isSelected
                                  ? themeData.primaryColor
                                  : CupertinoColors.systemGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              SizedBox(width: 16),
              CupertinoButton.filled(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                onPressed: _updateBudget,
                child: Text('Save Changes'),
              ),
            ],
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
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}