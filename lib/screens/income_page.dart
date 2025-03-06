//income_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<Transaction> incomeTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    incomeTransactions = await DatabaseHelper.instance.getTransactionsByType('income');
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = incomeTransactions.fold(
        0, (sum, transaction) => sum + transaction.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Income'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadIncomes,
              child: Column(
                children: [
                  // Income summary card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Income',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₱${totalIncome.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Income list
                  Expanded(
                    child: incomeTransactions.isEmpty
                        ? Center(
                            child: Text(
                              'No income recorded yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: incomeTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionListItem(
                                transaction: incomeTransactions[index],
                                onDelete: () async {
                                  await DatabaseHelper.instance
                                      .deleteTransaction(incomeTransactions[index].id!);
                                  _loadIncomes();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddTransactionSheet(
              transactionType: 'income',
              onTransactionAdded: () {
                _loadIncomes();
              },
            ),
          );
        },
      ),
    );
  }
}