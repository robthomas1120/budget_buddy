// lib/widgets/transaction_list_item.dart
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';
import 'transaction_details_dialog.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    final bool isIncome = transaction.type == 'income';
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final transactionColor = isIncome ? themeData.incomeColor : themeData.expenseColor;

    // Define item-specific text style
    final itemTextStyle = TextStyle(
      color: themeData.textColor,
      fontSize: 14,
    );

    return DefaultTextStyle(
      style: itemTextStyle,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeData.brightness == Brightness.dark 
                  ? CupertinoColors.black.withOpacity(0.2)
                  : CupertinoColors.systemGrey6,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return TransactionDetailsDialog(
                  transaction: transaction,
                  onDelete: onDelete,
                  onUpdate: onUpdate,
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: transactionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIncome ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
                    color: transactionColor,
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
                          fontSize: 16,
                          color: transactionColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${transaction.category} • ${formatter.format(transaction.date)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transactionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}