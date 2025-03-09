// lib/screens/budget_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';
import '../widgets/budget_detail_sheet.dart';
import '../widgets/add_budget_sheet.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Budget> _budgets = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

Future<void> _loadBudgets() async {
  setState(() {
    _isLoading = true;
  });

  print('DEBUG: Starting to load budgets');
  
  // First recalculate all active budgets to ensure accurate data
  await DatabaseHelper.instance.recalculateAllActiveBudgets();
  print('DEBUG: Recalculated all active budgets');
  
  // Then fetch the updated budgets
  final budgets = await DatabaseHelper.instance.getAllBudgets();
  print('DEBUG: Loaded ${budgets.length} budgets from database');
  
  // Debug print each budget's details
  for (var budget in budgets) {
    print('DEBUG: Budget ID: ${budget.id}, Category: ${budget.category}');
    print('DEBUG: Amount: ${budget.amount}, Spent: ${budget.spent}');
    print('DEBUG: Period: ${budget.period}, Active: ${budget.isActive}');
    print('DEBUG: Account IDs: ${budget.accountIds}');
    print('-----');
  }
  
  if (mounted) {
    setState(() {
      _budgets = budgets;
      _isLoading = false;
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
        middle: Text('Budgets', style: TextStyle(color: themeData.textColor)),
        backgroundColor: themeData.cardColor,
        trailing: GestureDetector(
          onTap: () => _showAddBudgetSheet(context),
          child: Icon(CupertinoIcons.add, color: themeData.primaryColor),
        ),
      ),
      child: _isLoading 
        ? Center(child: CupertinoActivityIndicator())
        : _budgets.isEmpty 
          ? _buildEmptyState(themeData)
          : _buildBudgetsList(themeData),
    );
  }

  Widget _buildEmptyState(AppThemeData themeData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.money_dollar_circle,
            size: 80,
            color: themeData.brightness == Brightness.dark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey4,
          ),
          SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a budget to track your spending',
            style: TextStyle(
              color: themeData.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          CupertinoButton.filled(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: () => _showAddBudgetSheet(context),
            child: Text('Add Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsList(AppThemeData themeData) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _loadBudgets,
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final budget = _budgets[index];
                return _buildBudgetCard(budget, themeData);
              },
              childCount: _budgets.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget, AppThemeData themeData) {
    // Calculate progress percentage
    final progress = budget.progress.clamp(0.0, 1.0);
    
    // Determine status color
    Color statusColor = themeData.primaryColor;
    if (progress > 0.9) {
      statusColor = themeData.expenseColor;
    } else if (progress > 0.7) {
      statusColor = CupertinoColors.systemOrange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeData.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.2)
                : CupertinoColors.systemGrey6,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showBudgetDetails(budget),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: themeData.textColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: budget.isActive 
                          ? themeData.primaryColor.withOpacity(0.1)
                          : CupertinoColors.systemGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      budget.isActive ? 'Active' : 'Expired',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: budget.isActive 
                            ? themeData.primaryColor
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                budget.period == 'weekly' ? 'Weekly Budget' : 'Monthly Budget',
                style: TextStyle(
                  fontSize: 14,
                  color: themeData.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd').format(budget.endDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeData.textColor.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey.withOpacity(0.2)
                          : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.8 * progress,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₱${budget.spent.toStringAsFixed(2)} spent',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '₱${budget.amount.toStringAsFixed(2)} budget',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                budget.isOverBudget 
                    ? 'Over budget by ₱${(budget.spent - budget.amount).toStringAsFixed(2)}'
                    : '₱${budget.remaining.toStringAsFixed(2)} remaining',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: budget.isOverBudget ? themeData.expenseColor : themeData.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDetails(Budget budget) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => BudgetDetailSheet(
        budget: budget,
        onBudgetUpdated: _loadBudgets,
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddBudgetSheet(
        onBudgetAdded: _loadBudgets,
      ),
    );
  }
}