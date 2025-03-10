// lib/widgets/savings_goal_details_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/savings_goal.dart';
import '../providers/theme_provider.dart';
import 'savings_helper.dart';

class SavingsGoalDetailsSheet extends StatelessWidget {
  final SavingsGoal goal;
  final List<Account> accounts;
  final Function(SavingsGoal) onGoalUpdated;
  final Function(int) onGoalDeleted;

  const SavingsGoalDetailsSheet({
    Key? key,
    required this.goal,
    required this.accounts,
    required this.onGoalUpdated,
    required this.onGoalDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    final progress = goal.progressPercentage;
    
    // Find associated account name, if any
    String accountName = "Not linked to any account";
    if (goal.accountId != null) {
      final account = accounts.firstWhere(
        (acc) => acc.id == goal.accountId,
        orElse: () => Account(id: 0, name: "Unknown", type: "unknown", balance: 0),
      );
      accountName = account.name;
    }
    
    return DefaultTextStyle(
      style: TextStyle(
        color: themeData.textColor,
        fontSize: 14.0,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings Goal Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeData.textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.xmark_circle, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeData.brightness == Brightness.dark
                      ? Color(0xFF2C2C2E) // Darker gray
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      goal.reason,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeData.textColor.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 16),
                    _detailRow('Target Amount', '₱${goal.targetAmount.toStringAsFixed(2)}', themeData),
                    _detailRow('Current Amount', '₱${goal.currentAmount.toStringAsFixed(2)}', themeData),
                    _detailRow('Remaining', '₱${(goal.targetAmount - goal.currentAmount).toStringAsFixed(2)}', themeData),
                    _detailRow('Account', accountName, themeData),
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
                          width: (MediaQuery.of(context).size.width - 64) * progress,
                          decoration: BoxDecoration(
                            color: themeData.primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% Complete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: themeData.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    _detailRow('Start Date', DateFormat('MMM dd, yyyy').format(goal.startDate), themeData),
                    _detailRow('Target Date', DateFormat('MMM dd, yyyy').format(goal.targetDate), themeData),
                    _detailRow('Days Remaining', '${goal.daysRemaining} days', themeData),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeData.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Savings Recommendations:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeData.primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          _recommendationRow('Daily', '₱${goal.dailySavingsNeeded.toStringAsFixed(2)}', themeData),
                          _recommendationRow('Weekly', '₱${goal.weeklySavingsNeeded.toStringAsFixed(2)}', themeData),
                          _recommendationRow('Monthly', '₱${goal.monthlySavingsNeeded.toStringAsFixed(2)}', themeData),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Functionality to add money to the savings goal
                      _showAddFundsSheet(context, goal, themeData);
                    },
                    child: Text('Add Funds', style: TextStyle(color: themeData.primaryColor)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Functionality to edit the savings goal
                      _showEditSavingsGoalSheet(context, goal, accounts, themeData);
                    },
                    child: Text('Edit Goal'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Functionality to delete the savings goal
                      _confirmDeleteSavingsGoal(context, goal, themeData);
                    },
                    child: Text('Delete', style: TextStyle(color: themeData.expenseColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, AppThemeData themeData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: themeData.textColor.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeData.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationRow(String period, String amount, AppThemeData themeData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$period: ',
            style: TextStyle(
              fontSize: 14,
              color: themeData.textColor,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeData.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFundsSheet(BuildContext context, SavingsGoal goal, AppThemeData themeData) {
    print('DEBUG: [SavingsGoalDetailsSheet] Opening add funds sheet for ${goal.name}');

    final TextEditingController amountController = TextEditingController();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: TextStyle(
          color: themeData.textColor,
          fontSize: 14.0,
        ),
        child: Container(
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
                      'Add Funds to ${goal.name}',
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
                            print('DEBUG: [SavingsGoalDetailsSheet] Invalid amount entered: ${amountController.text}');

                            SavingsHelper.showError(context, 'Please enter a valid amount');
                            return;
                          }

                          print('DEBUG: [SavingsGoalDetailsSheet] Adding $amount to goal ${goal.name}');
                          print('DEBUG: [SavingsGoalDetailsSheet] Before: ${goal.currentAmount}, After: ${goal.currentAmount + amount}');

                          // Create updated goal with new amount
                          final updatedGoal = goal.copyWith(
                            currentAmount: goal.currentAmount + amount,
                          );
                          
                          // Call the callback with the updated goal
                          onGoalUpdated(updatedGoal);
                          print('DEBUG: [SavingsGoalDetailsSheet] Goal updated successfully');

                          Navigator.pop(context); // Close the add funds sheet
                          Navigator.pop(context); // Close the details sheet
                        },
                        child: Text('Add Funds'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSavingsGoalSheet(
    BuildContext context, 
    SavingsGoal goal, 
    List<Account> accounts, 
    AppThemeData themeData,
  ) {
    final TextEditingController nameController = TextEditingController(text: goal.name);
    final TextEditingController reasonController = TextEditingController(text: goal.reason);
    final TextEditingController amountController = TextEditingController(text: goal.targetAmount.toString());
    final TextEditingController currentAmountController = TextEditingController(text: goal.currentAmount.toString());
    
    DateTime targetDate = goal.targetDate;
    Account? selectedAccount;
    
    // Make sure we have a valid selectedAccount that exists in the accounts list
    if (accounts.isEmpty) {
      // No accounts available, don't show account selection
      selectedAccount = null;
    } else if (goal.accountId != null) {
      // Try to find the account by ID
      try {
        selectedAccount = accounts.firstWhere((acc) => acc.id == goal.accountId);
      } catch (e) {
        // If not found, use the first account
        selectedAccount = accounts.first;
      }
    } else {
      // No account ID, use the first account
      selectedAccount = accounts.first;
    }
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: TextStyle(
          color: themeData.textColor,
          fontSize: 14.0,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Savings Goal',
                          style: TextStyle(
                            fontSize: 20,
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
                    
                    // Name Field
                    Text(
                      'Goal Name:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: themeData.brightness == Brightness.dark
                            ? Color(0xFF2C2C2E) // Darker gray
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: TextStyle(color: themeData.textColor),
                    ),
                    SizedBox(height: 16),
                    
                    // Reason Field
                    Text(
                      'Reason:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: reasonController,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: themeData.brightness == Brightness.dark
                            ? Color(0xFF2C2C2E) // Darker gray
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: TextStyle(color: themeData.textColor),
                    ),
                    SizedBox(height: 16),
                    
                    // Target Amount Field
                    Text(
                      'Target Amount:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: amountController,
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
                    SizedBox(height: 16),
                    
                    // Current Amount Field
                    Text(
                      'Current Amount:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: currentAmountController,
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
                    SizedBox(height: 16),
                    
                    // Target Date Field
                    Text(
                      'Target Date:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: themeData.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        await SavingsHelper.showDatePicker(
                          context, 
                          themeData, 
                          targetDate, 
                          (date) {
                            setState(() {
                              targetDate = date;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: themeData.brightness == Brightness.dark
                              ? Color(0xFF2C2C2E) // Darker gray
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(targetDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: themeData.textColor,
                              ),
                            ),
                            Icon(CupertinoIcons.calendar, color: CupertinoColors.systemGrey),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Account Selection
                    if (accounts.isNotEmpty) ...[
                      Text(
                        'Associated Account:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: themeData.textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Material(  // Needed for DropdownButton
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          decoration: BoxDecoration(
                            color: themeData.brightness == Brightness.dark
                                ? Color(0xFF2C2C2E) // Darker gray
                                : CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Account>(
                              value: selectedAccount,
                              isExpanded: true,
                              icon: Icon(CupertinoIcons.chevron_down, size: 16, color: themeData.textColor),
                              style: TextStyle(
                                color: themeData.textColor,
                                fontSize: 16,
                              ),
                              dropdownColor: themeData.cardColor,
                              items: accounts.map((Account account) {
                                return DropdownMenuItem<Account>(
                                  value: account,
                                  child: Row(
                                    children: [
                                      Icon(
                                        SavingsHelper.getAccountIcon(account.type),
                                        color: SavingsHelper.getAccountColor(account.type),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        account.name,
                                        style: TextStyle(color: themeData.textColor),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (Account? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedAccount = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        borderRadius: BorderRadius.circular(8),
                        color: themeData.primaryColor,
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            SavingsHelper.showError(context, 'Please enter a goal name');
                            return;
                          }

                          final targetAmount = double.tryParse(amountController.text);
                          if (targetAmount == null || targetAmount <= 0) {
                            SavingsHelper.showError(context, 'Please enter a valid target amount');
                            return;
                          }

                          final currentAmount = double.tryParse(currentAmountController.text);
                          if (currentAmount == null || currentAmount < 0) {
                            SavingsHelper.showError(context, 'Please enter a valid current amount');
                            return;
                          }

                          if (targetDate.isBefore(DateTime.now())) {
                            SavingsHelper.showError(context, 'Target date must be in the future');
                            return;
                          }

                          // Create updated goal
                          final updatedGoal = goal.copyWith(
                            name: nameController.text.trim(),
                            reason: reasonController.text.trim(),
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            targetDate: targetDate,
                            accountId: selectedAccount?.id,
                          );

                          // Call the callback with the updated goal
                          onGoalUpdated(updatedGoal);
                          Navigator.pop(context); // Close the edit sheet
                          Navigator.pop(context); // Close the details sheet
                        },
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSavingsGoal(
    BuildContext context, 
    SavingsGoal goal, 
    AppThemeData themeData,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => DefaultTextStyle(
        style: TextStyle(
          color: themeData.textColor,
          fontSize: 14.0,
        ),
        child: CupertinoAlertDialog(
          title: Text('Delete Savings Goal'),
          content: Text('Are you sure you want to delete "${goal.name}"? This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Delete'),
              onPressed: () {
                onGoalDeleted(goal.id!);
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Close the details sheet
              },
            ),
          ],
        ),
      ),
    );
  }
}