// lib/widgets/budget_detail_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';
import 'edit_budget_sheet.dart';

class BudgetDetailSheet extends StatefulWidget {
  final Budget budget;
  final VoidCallback onBudgetUpdated;

  const BudgetDetailSheet({
    Key? key, 
    required this.budget,
    required this.onBudgetUpdated,
  }) : super(key: key);

  @override
  _BudgetDetailSheetState createState() => _BudgetDetailSheetState();
}

class _BudgetDetailSheetState extends State<BudgetDetailSheet> {
  List<Account> _associatedAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssociatedAccounts();
  }

  Future<void> _loadAssociatedAccounts() async {
    setState(() => _isLoading = true);

    List<Account> accounts = [];
    if (widget.budget.accountIds != null && widget.budget.accountIds!.isNotEmpty) {
      for (int id in widget.budget.accountIds!) {
        final account = await DatabaseHelper.instance.getAccount(id);
        if (account != null) {
          accounts.add(account);
        }
      }
    }

    if (mounted) {
      setState(() {
        _associatedAccounts = accounts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return DefaultTextStyle(  // Added DefaultTextStyle wrapper
      style: TextStyle(
        color: themeData.textColor,
        fontFamily: '.SF Pro Text',
        fontSize: 16.0,
      ),
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
            : _buildContent(themeData),
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeData themeData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
                decoration: TextDecoration.none,  // Explicitly remove decoration
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.xmark_circle, color: CupertinoColors.systemGrey),
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeData.brightness == Brightness.dark
                ? Color(0xFF2C2C2E) // Darker gray
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildBudgetInfo(themeData),
        ),
        SizedBox(height: 16),
        _buildAccountsList(themeData),
        SizedBox(height: 20),
        _buildActionButtons(themeData),
      ],
    );
  }

  Widget _buildBudgetInfo(AppThemeData themeData) {
    final budget = widget.budget;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          budget.category,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeData.textColor,
            decoration: TextDecoration.none,  // Explicitly remove decoration
          ),
        ),
        SizedBox(height: 4),
        Text(
          budget.period == 'weekly' ? 'Weekly Budget' : 'Monthly Budget',
          style: TextStyle(
            fontSize: 16,
            color: themeData.textColor.withOpacity(0.7),
            decoration: TextDecoration.none,  // Explicitly remove decoration
          ),
        ),
        SizedBox(height: 16),
        _detailRow('Budget Amount', '₱${budget.amount.toStringAsFixed(2)}', themeData),
        _detailRow('Spent', '₱${budget.spent.toStringAsFixed(2)}', themeData),
        _detailRow(
          'Remaining', 
          budget.isOverBudget 
              ? '-₱${(budget.spent - budget.amount).abs().toStringAsFixed(2)}' 
              : '₱${budget.remaining.toStringAsFixed(2)}',
          themeData,
          valueColor: budget.isOverBudget ? themeData.expenseColor : themeData.primaryColor,
        ),
        SizedBox(height: 8),
        _detailRow('Period', '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd').format(budget.endDate)}', themeData),
        SizedBox(height: 8),
        Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            color: themeData.textColor.withOpacity(0.7),
            decoration: TextDecoration.none,  // Explicitly remove decoration
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: budget.isActive 
                    ? themeData.primaryColor.withOpacity(0.1)
                    : CupertinoColors.systemGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent),  // Clear any borders
              ),
              child: Text(
                budget.isActive ? 'Active' : 'Expired',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: budget.isActive 
                      ? themeData.primaryColor
                      : CupertinoColors.systemGrey,
                  decoration: TextDecoration.none,  // Explicitly remove decoration
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: budget.isOverBudget 
                    ? themeData.expenseColor.withOpacity(0.1)
                    : themeData.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent),  // Clear any borders
              ),
              child: Text(
                budget.isOverBudget ? 'Over Budget' : 'Within Budget',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: budget.isOverBudget 
                      ? themeData.expenseColor
                      : themeData.primaryColor,
                  decoration: TextDecoration.none,  // Explicitly remove decoration
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountsList(AppThemeData themeData) {
    if (_associatedAccounts.isEmpty) {
      return Text(
        'All accounts included in this budget',
        style: TextStyle(
          fontSize: 14,
          color: themeData.textColor.withOpacity(0.7),
          decoration: TextDecoration.none,  // Explicitly remove decoration
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accounts Included:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeData.textColor,
            decoration: TextDecoration.none,  // Explicitly remove decoration
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _associatedAccounts.length,
            itemBuilder: (context, index) {
              final account = _associatedAccounts[index];
              return Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getAccountColor(account.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.transparent),  // Clear any borders
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAccountIcon(account.type),
                      color: _getAccountColor(account.type),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      account.name,
                      style: TextStyle(
                        color: themeData.textColor,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,  // Explicitly remove decoration
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppThemeData themeData) {
    return Row(
      mainAxisAlignment: widget.budget.isExpired ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.end,
      children: [
        if (widget.budget.isExpired)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.renewBudget(widget.budget);
              widget.onBudgetUpdated();
            },
            child: Text('Renew Budget'),
          ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            Navigator.pop(context);
            await DatabaseHelper.instance.deleteBudget(widget.budget.id!);
            widget.onBudgetUpdated();
          },
          child: Text('Delete', style: TextStyle(color: themeData.expenseColor)),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
            _showEditBudgetSheet();
          },
          child: Text('Edit'),
        ),
      ],
    );
  }

  void _showEditBudgetSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => EditBudgetSheet(
        budget: widget.budget,
        onBudgetUpdated: widget.onBudgetUpdated,
      ),
    );
  }

  Widget _detailRow(String label, String value, AppThemeData themeData, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: themeData.textColor.withOpacity(0.7),
              decoration: TextDecoration.none,  // Explicitly remove decoration
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? themeData.textColor,
              decoration: TextDecoration.none,  // Explicitly remove decoration
            ),
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