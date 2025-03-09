import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
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

    // Get the total balance from all accounts
    final totalBalance = await DatabaseHelper.instance.getTotalBalance();
    final income = await DatabaseHelper.instance.getTotalIncome();
    final expenses = await DatabaseHelper.instance.getTotalExpense();
    final recentTransactions = await DatabaseHelper.instance.getRecentTransactions(5);

    if (mounted) {
      setState(() {
        _currentBalance = totalBalance;
        _totalIncome = income;
        _totalExpenses = expenses;
        _recentTransactions = recentTransactions;
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

  // Add a method to handle updating transactions
  void _updateTransaction(Transaction transaction) {
    // Here you would typically show a form to edit the transaction
    // For now, we'll just reload the data
    _loadData();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return CupertinoPageScaffold(
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
                            income: _totalIncome,
                            expenses: _totalExpenses,
                            onBalanceTap: _navigateToAccountsPage,
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeData.textColor,
                                  // Remove any decoration that might be causing the yellow underline
                                  decoration: TextDecoration.none,
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
    );
  }
}