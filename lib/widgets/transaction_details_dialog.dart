import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../providers/theme_provider.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TransactionDetailsDialog> createState() => _TransactionDetailsDialogState();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    final transaction = widget.transaction;
    final isIncome = transaction.type == 'income';
    final transactionColor = isIncome ? themeData.incomeColor : themeData.expenseColor;

    // Define a default text style based on the theme
    final defaultTextStyle = TextStyle(
      color: themeData.textColor,
      fontFamily: '.SF Pro Text',
      fontSize: 14,
    );

    return DefaultTextStyle(
      style: defaultTextStyle,
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
        decoration: BoxDecoration(
          color: themeData.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 12),
                color: CupertinoColors.separator,
              ),
              const SizedBox(height: 8),
              
              // Transaction header
              Row(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: transactionColor,
                          ),
                        ),
                        Text(
                          '${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                          style: const TextStyle(
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
                      color: transactionColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Account info
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (_account != null)
                _buildAccountInfo(_account!, themeData),
              
              const SizedBox(height: 16),
              
              // Notes
              if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                const Text(
                  'Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeData.brightness == Brightness.dark 
                        ? CupertinoColors.systemGrey6.darkColor
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.notes!,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                            color: themeData.expenseColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: themeData.expenseColor,
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
                            color: themeData.secondaryColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: themeData.secondaryColor,
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
      ),
    );
  }

  Widget _buildAccountInfo(Account account, AppThemeData themeData) {
    return DefaultTextStyle(
      style: TextStyle(color: themeData.textColor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeData.brightness == Brightness.dark 
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getAccountIcon(account.type),
              color: _getAccountColor(account.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account:',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  account.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '₱${account.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? themeData.incomeColor : themeData.expenseColor,
              ),
            ),
          ],
        ),
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