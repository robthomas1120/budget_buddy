import 'package:flutter/cupertino.dart';
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
      if (mounted) {
        setState(() {
          _account = account;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isIncome = transaction.type == 'income';

    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(CupertinoIcons.xmark, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(vertical: 12),
              color: CupertinoColors.separator,
            ),
            SizedBox(height: 8),
            
            // Transaction header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isIncome ? CupertinoColors.activeGreen.withOpacity(0.15) : CupertinoColors.destructiveRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIncome ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
                    color: isIncome ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                    size: 24,
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
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isIncome ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Account info
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (_account != null)
              _buildAccountInfo(_account!),
            
            SizedBox(height: 16),
            
            // Notes
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.notes!,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDelete();
                    },
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.delete,
                          color: CupertinoColors.destructiveRed,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onUpdate();
                    },
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.pencil,
                          color: CupertinoColors.activeBlue,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getAccountIcon(account.type),
            color: _getAccountColor(account.type),
            size: 24,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account:',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Text(
                account.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '₱${account.balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: account.balance >= 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return CupertinoIcons.building_2_fill;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoIcons.creditcard_fill;
      case 'cash':
        return CupertinoIcons.money_dollar_circle_fill;
      default:
        return CupertinoIcons.creditcard_fill;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return CupertinoColors.systemBlue;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoColors.systemPurple;
      case 'cash':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemIndigo;
    }
  }
}