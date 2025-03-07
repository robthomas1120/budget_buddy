// widgets/transaction_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../models/account.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final Transaction transaction;
  final Function onUpdate;
  final Function onDelete;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _TransactionDetailsDialogState createState() => _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  Account? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.transaction.accountId != null) {
      final account = await DatabaseHelper.instance.getAccount(widget.transaction.accountId!);
      setState(() {
        _account = account;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isIncome = transaction.type == 'income';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_account != null)
              _buildAccountInfo(_account!),
            SizedBox(height: 16),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(transaction.notes!),
              SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onUpdate();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(Account account) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getAccountIcon(account.type),
            color: _getAccountColor(account.type),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                account.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '₱${account.balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: account.balance >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'cash':
        return Icons.money;
      default:
        return Icons.credit_card;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Colors.blue;
      case 'e-wallet':
      case 'ewallet':
        return Colors.purple;
      case 'cash':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}