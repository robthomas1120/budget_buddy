import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'transaction_details_dialog.dart'; // Import the new dialog

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: Key(transaction.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this transaction?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${transaction.category} • ${formatter.format(transaction.date)}',
          ),
          trailing: Text(
            '₱${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // Show transaction details dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TransactionDetailsDialog(
                  transaction: transaction,
                );
              },
            );
          },
        ),
      ),
    );
  }
}