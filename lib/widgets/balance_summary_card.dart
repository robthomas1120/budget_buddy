// widgets/balance_summary_card.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String _balanceVisibilityKey = 'balance_visibility';

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibilityPreference();
  }
  
  // Load saved preference for balance visibility
  Future<void> _loadBalanceVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible = prefs.getBool(_balanceVisibilityKey) ?? false;
    });
  }
  
  // Save balance visibility preference
  Future<void> _saveBalanceVisibilityPreference(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_balanceVisibilityKey, isVisible);
  }

  // Toggle balance visibility
  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      _saveBalanceVisibilityPreference(_isBalanceVisible);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.green,
      child: InkWell(
        onTap: () => widget.onBalanceTap(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _toggleBalanceVisibility,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.trending_up,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _isBalanceVisible 
                      ? '₱${widget.currentBalance.toStringAsFixed(2)}'
                      : '₱ ------',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
              // No income or expenses row - removed as requested
            ],
          ),
        ),
      ),
    );
  }
}