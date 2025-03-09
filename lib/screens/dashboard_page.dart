// lib/screens/dashboard_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../providers/theme_provider.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';
import 'accounts_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _currentBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<Transaction> _recentTransactions = [];
  List<Budget> _activeBudgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final totalBalance = await DatabaseHelper.instance.getTotalBalance();
    final income = await DatabaseHelper.instance.getTotalIncome();
    final expenses = await DatabaseHelper.instance.getTotalExpense();
    final recentTransactions = await DatabaseHelper.instance.getRecentTransactions(5);
    final activeBudgets = await DatabaseHelper.instance.getActiveBudgets();

    if (mounted) {
      setState(() {
        _currentBalance = totalBalance;
        _totalIncome = income;
        _totalExpenses = expenses;
        _recentTransactions = recentTransactions;
        _activeBudgets = activeBudgets;
        _isLoading = false;
      });
    }
  }

  void _showAddTransactionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddTransactionSheet(
        onTransactionAdded: _loadData,
      ),
    );
  }

  void _navigateToAccountsPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AccountsPage()),
    ).then((_) => _loadData());
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _loadData();
      
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Transaction deleted successfully'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete transaction: $e'),
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
  }

  void _updateTransaction(Transaction transaction) {
    _loadData();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Define text style specifically for this page
    final pageTextStyle = TextStyle(
      color: themeData.textColor,
      fontFamily: '.SF Pro Text',
      fontSize: 16.0,
    );
    
    return DefaultTextStyle(
      style: pageTextStyle,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Finance Tracker'),
          backgroundColor: themeData.cardColor,
          trailing: GestureDetector(
            onTap: _loadData,
            child: Icon(CupertinoIcons.refresh, color: themeData.primaryColor),
          ),
        ),
        backgroundColor: themeData.backgroundColor,
        child: Stack(
          children: [
            _isLoading 
              ? Center(child: CupertinoActivityIndicator()) 
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: _loadData,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BalanceSummaryCard(
                              currentBalance: _currentBalance,
                              onBalanceTap: _navigateToAccountsPage,
                            ),
                            SizedBox(height: 24),
                            
                            // Budget summary section
                            _buildBudgetSummary(themeData),
                            
                            // Recent transactions section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeData.textColor,
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    // Navigate to all transactions page
                                  },
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      color: themeData.secondaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _recentTransactions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            CupertinoIcons.doc_text,
                                            size: 48,
                                            color: CupertinoColors.systemGrey4,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'No transactions yet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Add your first transaction by tapping the + button',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _recentTransactions.length,
                                    itemBuilder: (context, index) {
                                      final transaction = _recentTransactions[index];
                                      return TransactionListItem(
                                        transaction: transaction,
                                        onDelete: () => _deleteTransaction(transaction.id!),
                                        onUpdate: () => _updateTransaction(transaction),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
            // Floating action button positioned at the bottom right
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: _showAddTransactionSheet,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: themeData.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this widget to your dashboard_page.dart file

Widget _buildBudgetSummary(AppThemeData themeData) {
  if (_activeBudgets.isEmpty) {
    return SizedBox.shrink(); // Don't show anything if no active budgets
  }
  
  // Sort budgets by remaining percentage (low to high)
  _activeBudgets.sort((a, b) => (a.spent / a.amount).compareTo(b.spent / b.amount));
  
  // Take top 3 budgets with highest percentage used
  final topBudgets = _activeBudgets.length > 3 
      ? _activeBudgets.sublist(_activeBudgets.length - 3) 
      : _activeBudgets;
      
  // Calculate total budget and spent for the period
  double totalBudget = 0;
  double totalSpent = 0;
  for (var budget in _activeBudgets) {
    totalBudget += budget.amount;
    totalSpent += budget.spent;
  }
  
  final overallProgress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
  final overallColor = overallProgress > 0.9 
      ? themeData.expenseColor 
      : overallProgress > 0.7 
          ? CupertinoColors.systemOrange 
          : themeData.primaryColor;
  
  return Container(
    margin: EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Budgets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'View All',
                style: TextStyle(
                  color: themeData.secondaryColor,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                // Navigate to the Budgets tab (index 3)
                final CupertinoTabController? tabController = 
                    context.findAncestorWidgetOfExactType<CupertinoTabScaffold>()?.controller;
                if (tabController != null) {
                  tabController.index = 3;
                }
              },
            ),
          ],
        ),
        
        // Overall budget progress card
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          padding: EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Budget',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: themeData.textColor,
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: overallColor,
                    ),
                  ),
                ],
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
                    width: MediaQuery.of(context).size.width * 0.85 * overallProgress,
                    decoration: BoxDecoration(
                      color: overallColor,
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
                    'Spent: ₱${totalSpent.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Total: ₱${totalBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              if (totalSpent > totalBudget)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Over budget by ₱${(totalSpent - totalBudget).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: themeData.expenseColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Individual budget items
        Column(
          children: topBudgets.reversed.map((budget) {
            // Calculate progress
            final progress = budget.progress.clamp(0.0, 1.0);
            
            // Determine status color
            Color statusColor = themeData.primaryColor;
            if (progress > 0.9) {
              statusColor = themeData.expenseColor;
            } else if (progress > 0.7) {
              statusColor = CupertinoColors.systemOrange;
            }
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeData.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: themeData.brightness == Brightness.dark 
                        ? Colors.black.withOpacity(0.1)
                        : CupertinoColors.systemGrey6,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
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
                          fontSize: 16,
                          color: themeData.textColor,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₱${budget.spent.toStringAsFixed(2)} / ₱${budget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeData.brightness == Brightness.dark
                              ? CupertinoColors.systemGrey.withOpacity(0.2)
                              : CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: MediaQuery.of(context).size.width * 0.8 * progress,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    budget.isOverBudget 
                        ? 'Over budget by ₱${(budget.spent - budget.amount).toStringAsFixed(2)}'
                        : '₱${budget.remaining.toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: budget.isOverBudget ? themeData.expenseColor : themeData.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
}