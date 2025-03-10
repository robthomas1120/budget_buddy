// screens/income_page.dart

import 'package:flutter/cupertino.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/transaction_details_dialog.dart';



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
  showCupertinoModalPopup(
    context: context,
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
      showCupertinoDialog(
        context: context,
        builder: (context) => DefaultTextStyle(
          style: TextStyle(
            color: CupertinoColors.label,
            fontSize: 14.0,
          ),
          child: CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Transaction deleted successfully'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => DefaultTextStyle(
          style: TextStyle(
            color: CupertinoColors.label,
            fontSize: 14.0,
          ),
          child: CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete transaction: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _updateTransaction(Transaction transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddTransactionSheet(
        transactionType: 'income',
        onTransactionAdded: _loadTransactions,
        transaction: transaction, // Pass the transaction to edit
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Income'),
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
              color: CupertinoColors.activeGreen,
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
            'No income transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first income by tapping the + button',
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