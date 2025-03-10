// lib/widgets/savings_goal_card.dart

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/savings_goal.dart';
import '../providers/theme_provider.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final Function(SavingsGoal) onTap;

  const SavingsGoalCard({
    Key? key,
    required this.goal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Calculate progress percentage for the progress bar
    final progress = goal.progressPercentage;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        onPressed: () => onTap(goal),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: themeData.textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.daysRemaining > 30 
                        ? themeData.primaryColor.withOpacity(0.1)
                        : CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${goal.daysRemaining} days left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: goal.daysRemaining > 30 
                          ? themeData.primaryColor
                          : CupertinoColors.systemOrange,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                goal.reason,
                style: TextStyle(
                  fontSize: 14,
                  color: themeData.textColor.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: themeData.brightness == Brightness.dark
                          ? CupertinoColors.systemGrey.withOpacity(0.2)
                          : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.8 * progress,
                    decoration: BoxDecoration(
                      color: themeData.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₱${goal.currentAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '₱${goal.targetAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeData.textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Save ₱${goal.dailySavingsNeeded.toStringAsFixed(2)} daily to reach your goal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeData.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}