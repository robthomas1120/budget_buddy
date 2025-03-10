// lib/widgets/add_savings_goal_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/savings_goal.dart';
import '../providers/theme_provider.dart';
import 'savings_helper.dart';

class AddSavingsGoalSheet extends StatefulWidget {
  final List<Account> accounts;
  final Function(SavingsGoal) onGoalAdded;

  const AddSavingsGoalSheet({
    Key? key,
    required this.accounts,
    required this.onGoalAdded,
  }) : super(key: key);

  @override
  _AddSavingsGoalSheetState createState() => _AddSavingsGoalSheetState();
}

class _AddSavingsGoalSheetState extends State<AddSavingsGoalSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  DateTime targetDate = DateTime.now().add(Duration(days: 90));  // Default 3 months
  Account? selectedAccount;
  
  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      selectedAccount = widget.accounts.first;
    }
  }
  
  @override
  void didUpdateWidget(AddSavingsGoalSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If accounts list changed, ensure selectedAccount is valid
    if (widget.accounts != oldWidget.accounts && widget.accounts.isNotEmpty) {
      // Check if current selectedAccount is in the new accounts list
      if (selectedAccount == null || !widget.accounts.contains(selectedAccount)) {
        selectedAccount = widget.accounts.first;
      }
    }
  }
  
  @override
  void dispose() {
    nameController.dispose();
    reasonController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    return DefaultTextStyle(
      style: TextStyle(
        color: themeData.textColor,
        fontFamily: '.SF Pro Text',
        fontSize: 16,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Savings Goal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                  ),
                ),
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'e.g., New Laptop, Vacation Fund',
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
                  'Reason (Optional):',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: reasonController,
                  placeholder: 'Why are you saving?',
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
                SizedBox(height: 16),
                
                // Target Date Field
                Text(
                  'Target Date:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
                Text(
                  'Associated Account:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                
                widget.accounts.isEmpty 
                  ? Text(
                      'No accounts available. Please create an account first.',
                      style: TextStyle(
                        color: themeData.expenseColor,
                        fontSize: 14,
                      ),
                    )
                  : Material(  // Needed for DropdownButton
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
                            items: widget.accounts.map((Account account) {
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

                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        SavingsHelper.showError(context, 'Please enter a valid target amount');
                        return;
                      }

                      if (targetDate.isBefore(DateTime.now())) {
                        SavingsHelper.showError(context, 'Target date must be in the future');
                        return;
                      }

                      // Create new savings goal
                      final newGoal = SavingsGoal(
                        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID, would be assigned by DB in real app
                        name: nameController.text.trim(),
                        reason: reasonController.text.trim(),
                        targetAmount: amount,
                        startDate: DateTime.now(),
                        targetDate: targetDate,
                        accountId: selectedAccount?.id,
                      );

                      // Call the callback with the new goal
                      widget.onGoalAdded(newGoal);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Create Savings Goal',
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
    );
  }
}