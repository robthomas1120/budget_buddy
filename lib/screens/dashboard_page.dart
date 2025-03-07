// screens/dashboard_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
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

    setState(() {
      _currentBalance = totalBalance;
      _totalIncome = income;
      _totalExpenses = expenses;
      _recentTransactions = recentTransactions;
      _isLoading = false;
    });
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddTransactionSheet(
        onTransactionAdded: _loadData,
      ),
    );
  }

  void _navigateToAccountsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountsPage()),
    ).then((_) => _loadData());
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }

  // Add a method to handle updating transactions
  void _updateTransaction(Transaction transaction) {
    // Here you would typically show a form to edit the transaction
    // For now, we'll just reload the data
    print("Update transaction: ${transaction.title}");
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to all transactions page
                        },
                        child: Text('See All'),
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
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add your first transaction by tapping the + button',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}