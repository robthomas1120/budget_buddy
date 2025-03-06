//expense_page.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Transaction> expenseTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    expenseTransactions = await DatabaseHelper.instance.getTransactionsByType('expense');
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = expenseTransactions.fold(
        0, (sum, transaction) => sum + transaction.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: Column(
                children: [
                  // Expense summary card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
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
                          'Total Expenses',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₱${totalExpense.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expense list
                  Expanded(
                    child: expenseTransactions.isEmpty
                        ? Center(
                            child: Text(
                              'No expenses recorded yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: expenseTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionListItem(
                                transaction: expenseTransactions[index],
                                onDelete: () async {
                                  await DatabaseHelper.instance
                                      .deleteTransaction(expenseTransactions[index].id!);
                                  _loadExpenses();
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
              transactionType: 'expense',
              onTransactionAdded: () {
                _loadExpenses();
              },
            ),
          );
        },
      ),
    );
  }
}