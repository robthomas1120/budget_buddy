// screens/expense_page.dart

import 'package:flutter/cupertino.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
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

    final transactions = await DatabaseHelper.instance.getTransactionsByType('expense');

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

void _showAddTransactionSheet() {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => AddTransactionSheet(
      transactionType: 'expense',
      onTransactionAdded: _loadTransactions,
    ),
  );
}

  Future<void> _deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _loadTransactions();
      // Show a Cupertino alert instead of a Snackbar
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
    } catch (e) {
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

  // Add a method to handle updating transactions
  void _updateTransaction(Transaction transaction) {
    // Here you would typically show a form to edit the transaction
    // For now, we'll just reload the data
    print("Update expense transaction: ${transaction.title}");
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Expenses'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.refresh),
          onPressed: _loadTransactions,
        ),
      ),
      child: Stack(
        children: [
          _isLoading 
            ? Center(child: CupertinoActivityIndicator()) 
            : _transactions.isEmpty 
                ? _buildEmptyState() 
                : _buildTransactionsList(),
          Positioned(
            bottom: 16,
            right: 16,
            child: CupertinoButton(
              padding: EdgeInsets.all(16),
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(30),
              child: Icon(CupertinoIcons.add, color: CupertinoColors.white),
              onPressed: _showAddTransactionSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.money_dollar_circle,
            size: 80,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first expense by tapping the + button',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _loadTransactions,
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final transaction = _transactions[index];
                return TransactionListItem(
                  transaction: transaction,
                  onDelete: () => _deleteTransaction(transaction.id!),
                  onUpdate: () => _updateTransaction(transaction),
                );
              },
              childCount: _transactions.length,
            ),
          ),
        ),
      ],
    );
  }
}