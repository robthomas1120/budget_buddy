import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double totalIncome = 0;
  double totalExpense = 0;
  List<Transaction> recentTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load totals
    totalIncome = await DatabaseHelper.instance.getTotalIncome();
    totalExpense = await DatabaseHelper.instance.getTotalExpense();
    
    // Load recent transactions
    recentTransactions = await DatabaseHelper.instance.getRecentTransactions(10);
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadData();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance summary card
                      BalanceSummaryCard(
                        totalIncome: totalIncome,
                        totalExpense: totalExpense,
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Recent transactions section
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Recent transaction list
                      recentTransactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No transactions yet. Add some income or expenses!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: recentTransactions.length,
                              itemBuilder: (context, index) {
                                return TransactionListItem(
                                  transaction: recentTransactions[index],
                                  onDelete: () async {
                                    await DatabaseHelper.instance
                                        .deleteTransaction(recentTransactions[index].id!);
                                    _loadData();
                                  },
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddTransactionSheet(
              onTransactionAdded: () {
                _loadData();
              },
            ),
          );
        },
      ),
    );
  }
}