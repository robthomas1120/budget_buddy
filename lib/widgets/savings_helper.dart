// lib/widgets/savings_helper.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class SavingsHelper {
  // Helper function to show date picker
  static Future<void> showDatePicker(
    BuildContext context,
    AppThemeData themeData,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: themeData.cardColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel', style: TextStyle(color: themeData.secondaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done', style: TextStyle(color: themeData.secondaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime.now(),
                  maximumDate: DateTime.now().add(Duration(days: 1825)), // 5 years
                  onDateTimeChanged: (DateTime newDate) {
                    onDateSelected(newDate);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to show error dialogs
  static void showError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Helper function to get account icon
  static IconData getAccountIcon(String accountType) {
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

  // Helper function to get account color
  static Color getAccountColor(String accountType) {
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

  // Helper function to format currency
  static String formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  // Helper function to calculate progress percentage
  static double calculateProgress(double current, double target) {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  // Helper function to format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper function to calculate days remaining
  static int calculateDaysRemaining(DateTime targetDate) {
    return targetDate.difference(DateTime.now()).inDays;
  }

  // Helper function to show success dialog
  static void showSuccess(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Helper function to show confirm dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, 
    String title, 
    String message,
  ) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Confirm'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Helper function to adjust savings goal current amount
  static Future<void> adjustSavingsAmount(
    BuildContext context,
    AppThemeData themeData, 
    String title,
    double currentAmount,
    Function(double) onAmountChanged,
  ) async {
    final TextEditingController amountController = TextEditingController();
    
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeData.textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.xmark, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Current Total: ${formatCurrency(currentAmount)}',
                style: TextStyle(
                  fontSize: 15,
                  color: themeData.textColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Amount to Add:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: themeData.textColor,
                ),
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: amountController,
                placeholder: '0.00',
                prefix: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text('₱', style: TextStyle(color: themeData.textColor)),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: themeData.brightness == Brightness.dark
                      ? Color(0xFF2C2C2E) // Darker gray
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: themeData.textColor),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      color: themeData.brightness == Brightness.dark
                          ? Color(0xFF2C2C2E) // Darker gray
                          : CupertinoColors.systemGrey6,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          showError(context, 'Please enter a valid amount');
                          return;
                        }
                        
                        onAmountChanged(currentAmount + amount);
                        Navigator.pop(context);
                      },
                      child: Text('Add Amount'),
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

  // Helper function to get savings recommendation text
  static String getSavingsRecommendation(double dailyAmount, int daysRemaining) {
    if (daysRemaining <= 0) {
      return "Goal period has ended";
    }
    
    if (dailyAmount < 1) {
      return "Goal almost complete!";
    } else if (dailyAmount < 10) {
      return "Just a little each day will get you there";
    } else if (dailyAmount < 100) {
      return "Keep setting aside funds regularly";
    } else if (dailyAmount < 500) {
      return "Consider increasing your savings rate";
    } else {
      return "You might need to extend your timeline or adjust your goal";
    }
  }

  // Helper function to get progress color based on completion percentage
  static Color getProgressColor(AppThemeData themeData, double progress) {
    if (progress >= 0.9) {
      return CupertinoColors.systemGreen;
    } else if (progress >= 0.6) {
      return themeData.primaryColor;
    } else if (progress >= 0.3) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemOrange;
    }
  }

  // Helper function to get days remaining text with color
  static Widget getDaysRemainingWidget(AppThemeData themeData, int days) {
    Color textColor;
    
    if (days > 60) {
      textColor = themeData.primaryColor;
    } else if (days > 30) {
      textColor = CupertinoColors.systemYellow;
    } else if (days > 7) {
      textColor = CupertinoColors.systemOrange;
    } else if (days > 0) {
      textColor = CupertinoColors.systemRed;
    } else {
      textColor = CupertinoColors.systemGrey;
    }
    
    return Text(
      days > 0 ? '$days days left' : 'Period ended',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}