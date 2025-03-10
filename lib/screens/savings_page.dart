// lib/screens/savings_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/savings_goal.dart';
import '../providers/theme_provider.dart';
import '../database/database_helper.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/add_savings_goal_sheet.dart';
import '../widgets/savings_goal_details_sheet.dart';
import '../widgets/savings_helper.dart';

class SavingsPage extends StatefulWidget {
  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  List<SavingsGoal> _savingsGoals = [];
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Add some example goals for demonstration
    // In a real app, these would be loaded from a database
    _savingsGoals = [
      SavingsGoal(
        id: 1,
        name: "New Laptop",
        reason: "For work and personal projects",
        targetAmount: 50000,
        currentAmount: 15000,
        startDate: DateTime.now().subtract(Duration(days: 30)),
        targetDate: DateTime.now().add(Duration(days: 120)),
      ),
      SavingsGoal(
        id: 2,
        name: "Vacation Fund",
        reason: "Summer trip to Boracay",
        targetAmount: 30000,
        currentAmount: 5000,
        startDate: DateTime.now().subtract(Duration(days: 15)),
        targetDate: DateTime.now().add(Duration(days: 75)),
      ),
    ];
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load accounts
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      
      // TODO: In a real implementation, you would load savings goals from the database
      // This would require creating a new table and CRUD operations for savings goals
      
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddSavingsGoalSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddSavingsGoalSheet(
        accounts: _accounts,
        onGoalAdded: (newGoal) {
          setState(() {
            _savingsGoals.add(newGoal);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Savings Goals', style: TextStyle(color: themeData.textColor)),
        backgroundColor: themeData.cardColor,
        trailing: GestureDetector(
          onTap: _showAddSavingsGoalSheet,
          child: Icon(CupertinoIcons.add, color: themeData.primaryColor),
        ),
      ),
      child: _isLoading 
        ? Center(child: CupertinoActivityIndicator())
        : _savingsGoals.isEmpty 
          ? _buildEmptyState(themeData)
          : _buildSavingsGoalsList(themeData),
    );
  }

  Widget _buildEmptyState(AppThemeData themeData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.money_dollar_circle,
            size: 80,
            color: themeData.brightness == Brightness.dark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey4,
          ),
          SizedBox(height: 16),
          Text(
            'No savings goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a savings goal to track your progress',
            style: TextStyle(
              color: themeData.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          CupertinoButton.filled(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: _showAddSavingsGoalSheet,
            child: Text('Add Savings Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsList(AppThemeData themeData) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _savingsGoals.length,
      itemBuilder: (context, index) {
        return SavingsGoalCard(
          goal: _savingsGoals[index],
          onTap: (goal) {
            // Show goal details
            showCupertinoModalPopup(
              context: context,
              builder: (context) => SavingsGoalDetailsSheet(
                goal: goal,
                accounts: _accounts,
                onGoalUpdated: (updatedGoal) {
                  setState(() {
                    final index = _savingsGoals.indexWhere((g) => g.id == updatedGoal.id);
                    if (index != -1) {
                      _savingsGoals[index] = updatedGoal;
                    }
                  });
                },
                onGoalDeleted: (goalId) {
                  setState(() {
                    _savingsGoals.removeWhere((g) => g.id == goalId);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}