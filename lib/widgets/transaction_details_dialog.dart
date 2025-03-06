import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final DateFormat dateFormatter = DateFormat('MMMM dd, yyyy');
    final DateFormat timeFormatter = DateFormat('hh:mm a');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with transaction type and icon
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                  radius: 25,
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      transaction.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '₱${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
            
            Divider(height: 30),
            
            // Transaction details
            _buildDetailRow('Title', transaction.title),
            _buildDetailRow('Date', dateFormatter.format(transaction.date)),
            _buildDetailRow('Time', timeFormatter.format(transaction.date)),
            _buildDetailRow('Category', transaction.category),
            
            // Notes section (only if notes exist)
            if (transaction.notes != null && transaction.notes!.isNotEmpty) 
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.notes!,
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            SizedBox(height: 20),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}