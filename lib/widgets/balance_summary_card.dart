// widgets/balance_summary_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BalanceSummaryCard extends StatefulWidget {
  final double currentBalance;
  final double income;
  final double expenses;
  final Function onBalanceTap;

  const BalanceSummaryCard({
    Key? key,
    required this.currentBalance,
    required this.income,
    required this.expenses,
    required this.onBalanceTap,
  }) : super(key: key);

  @override
  _BalanceSummaryCardState createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return GestureDetector(
      onTap: () => widget.onBalanceTap(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeData.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  child: Icon(
                    _isBalanceVisible 
                        ? CupertinoIcons.eye 
                        : CupertinoIcons.eye_slash,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _isBalanceVisible 
                      ? '₱${widget.currentBalance.toStringAsFixed(2)}'
                      : '₱ ******',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}