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
  // Add a function to refresh the page
  final Function? onRefresh;
  
  const SavingsPage({Key? key, this.onRefresh}) : super(key: key);
  
  @override
  State<SavingsPage> createState() => SavingsPageState();
}

// Make this class public by removing the underscore
class SavingsPageState extends State<SavingsPage> {
  List<SavingsGoal> _savingsGoals = [];
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (like when returning to this tab)
    _loadData();
  }
  
  // Public method that can be called from outside
  void refreshData() {
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    print('DEBUG: [SavingsPage] Starting to load data');
    
    try {
      // Load accounts
      final accounts = await DatabaseHelper.instance.getAllAccounts();
      print('DEBUG: [SavingsPage] Loaded ${accounts.length} accounts');
      
      // Log account details for debugging
      for (var account in accounts) {
        print('DEBUG: [SavingsPage] Account ${account.id}: ${account.name} - Balance: ${account.balance}');
      }
      
      // Log current savings goals
      print('DEBUG: [SavingsPage] Current savings goals: ${_savingsGoals.length}');
      for (var goal in _savingsGoals) {
        print('DEBUG: [SavingsPage] Goal: ${goal.name}, Target: ${goal.targetAmount}, Current: ${goal.currentAmount}, Progress: ${(goal.progressPercentage * 100).toStringAsFixed(2)}%');
      }
      
      // Check transactions with matching titles to update goals
      await _updateGoalsFromTransactions();
      
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
          print('DEBUG: [SavingsPage] State updated with data');
        });
      }
    } catch (e) {
      print('DEBUG: [SavingsPage] Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Separated method for updating goals from transactions
  Future<void> _updateGoalsFromTransactions() async {
    if (_savingsGoals.isEmpty) return;
    
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    print('DEBUG: [SavingsPage] Checking ${transactions.length} transactions for matching savings goals');
    
    bool updatedAnyGoal = false;
    
    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        for (int i = 0; i < _savingsGoals.length; i++) {
          if (transaction.title.toLowerCase().contains(_savingsGoals[i].name.toLowerCase())) {
            print('DEBUG: [SavingsPage] Found matching transaction for goal "${_savingsGoals[i].name}": ${transaction.title}, Amount: ${transaction.amount}');
            
            final updatedGoal = _savingsGoals[i].copyWith(
              currentAmount: _savingsGoals[i].currentAmount + transaction.amount,
            );
            _savingsGoals[i] = updatedGoal;
            updatedAnyGoal = true;
            print('DEBUG: [SavingsPage] Updated goal current amount to: ${updatedGoal.currentAmount}');
          }
        }
      }
    }
    
    if (updatedAnyGoal && mounted) {
      setState(() {});
    }
  }

  void _showAddSavingsGoalSheet() {
    print('DEBUG: [SavingsPage] Showing add savings goal sheet');
    
    // Make sure we have the latest accounts
    _loadData().then((_) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => AddSavingsGoalSheet(
          accounts: _accounts,
          onGoalAdded: (newGoal) {
            print('DEBUG: [SavingsPage] New savings goal added: ${newGoal.name}, Target: ${newGoal.targetAmount}');

            setState(() {
              _savingsGoals.add(newGoal);
              print('DEBUG: [SavingsPage] Goal added to state, total goals: ${_savingsGoals.length}');
            });
          },
        ),
      ).then((_) {
        // Refresh after sheet is closed
        _loadData();
        
        // Also call the onRefresh callback if provided
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      });
    });
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
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _loadData,
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
              childCount: _savingsGoals.length,
            ),
          ),
        ),
      ],
    );
  }
}