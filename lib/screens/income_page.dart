// screens/income_page.dart

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
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final transactions = await DatabaseHelper.instance.getTransactionsByType('income');

    setState(() {
      _transactions = transactions;
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
        transactionType: 'income',
        onTransactionAdded: _loadTransactions,
      ),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _loadTransactions();
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
    print("Update income transaction: ${transaction.title}");
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : _transactions.isEmpty 
            ? _buildEmptyState() 
            : _buildTransactionsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No income yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first income by tapping the + button',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionListItem(
            transaction: transaction,
            onDelete: () => _deleteTransaction(transaction.id!),
            onUpdate: () => _updateTransaction(transaction),
          );
        },
      ),
    );
  }
}