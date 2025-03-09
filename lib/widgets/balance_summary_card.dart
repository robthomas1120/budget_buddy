// lib/widgets/balance_summary_card.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BalanceSummaryCard extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onBalanceTap;

  const BalanceSummaryCard({
    Key? key,
    required this.currentBalance,
    required this.onBalanceTap,
  }) : super(key: key);

  @override
  State<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Define a card-specific text style
    final cardTextStyle = TextStyle(
      color: CupertinoColors.white,
      fontFamily: '.SF Pro Text',
      fontSize: 14,
    );
    
    return DefaultTextStyle(
      style: cardTextStyle,
      child: GestureDetector(
        onTap: widget.onBalanceTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeData.primaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey4.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: const Icon(
                      CupertinoIcons.eye_slash,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _isBalanceVisible 
                        ? '₱${widget.currentBalance.toStringAsFixed(2)}'
                        : '₱ ******',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}