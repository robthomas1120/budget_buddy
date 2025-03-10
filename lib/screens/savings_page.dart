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
    
    // Initialize empty savingsGoals list
    List<SavingsGoal> savingsGoals = [];
    
    // Try to load active savings goals only
    try {
      savingsGoals = await DatabaseHelper.instance.getActiveSavingsGoals();
      print('DEBUG: [SavingsPage] Current active savings goals: ${savingsGoals.length}');
    } catch (e) {
      print('DEBUG: [SavingsPage] Error loading savings goals: $e');
      print('DEBUG: [SavingsPage] Table may not exist yet, continuing with empty list');
      savingsGoals = [];
    }
    
    // Update savings goals based on linked accounts
    List<SavingsGoal> updatedGoals = [];
    
    for (var goal in savingsGoals) {
      // Find the matching account if accountId is set
      if (goal.accountId != null) {
        final matchingAccount = accounts.firstWhere(
          (account) => account.id == goal.accountId,
          orElse: () => Account(id: 0, name: "", type: "", balance: 0),
        );
        
        if (matchingAccount.id != 0) {
          print('DEBUG: [SavingsPage] Goal: ${goal.name} has linked account: ${matchingAccount.name} with balance: ${matchingAccount.balance}');
          
          // Update the goal with the account balance
          final updatedGoal = goal.copyWith(
            currentAmount: matchingAccount.balance,
          );
          
          print('DEBUG: [SavingsPage] Updated goal current amount to: ${updatedGoal.currentAmount}');
          updatedGoals.add(updatedGoal);
          
          // Update the goal in the database
          try {
            await DatabaseHelper.instance.updateSavingsGoal(updatedGoal);
          } catch (e) {
            print('DEBUG: [SavingsPage] Error updating goal: $e');
          }
        } else {
          print('DEBUG: [SavingsPage] Goal: ${goal.name} has linked accountId: ${goal.accountId} but no matching account found');
          updatedGoals.add(goal);
        }
      } else {
        // No linked account, keep as is
        print('DEBUG: [SavingsPage] Goal: ${goal.name} has no linked account');
        updatedGoals.add(goal);
      }
      
      if (savingsGoals.isNotEmpty) {
        print('DEBUG: [SavingsPage] Goal: ${goal.name}, Target: ${goal.targetAmount}, Current: ${goal.currentAmount}, Progress: ${(goal.progressPercentage * 100).toStringAsFixed(2)}%');
      }
    }
    
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _savingsGoals = updatedGoals;
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

void _showAddSavingsGoalSheet() {
  print('DEBUG: [SavingsPage] Showing add savings goal sheet');
  
  // Make sure we have the latest accounts
  _loadData().then((_) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddSavingsGoalSheet(
        accounts: _accounts,
        onGoalAdded: (newGoal) async {
          print('DEBUG: [SavingsPage] New savings goal added: ${newGoal.name}, Target: ${newGoal.targetAmount}');
          
          try {
            // Always insert a new goal first to get a valid ID
            final goalId = await DatabaseHelper.instance.insertSavingsGoal(newGoal);
            print('DEBUG: [SavingsPage] Inserted goal with ID: $goalId');
            
            // If the goal has a linked account, set its current amount to the account balance
            if (newGoal.accountId != null) {
              final linkedAccount = _accounts.firstWhere(
                (account) => account.id == newGoal.accountId,
                orElse: () => Account(id: 0, name: "", type: "", balance: 0),
              );
              
              if (linkedAccount.id != 0) {
                print('DEBUG: [SavingsPage] Setting initial amount from linked account: ${linkedAccount.name} balance: ${linkedAccount.balance}');
                
                // Create updated goal with the valid ID and account balance
                final updatedGoal = newGoal.copyWith(
                  id: goalId,  // Make sure to set the ID from the insert operation
                  currentAmount: linkedAccount.balance,
                );
                
                // Now update the goal with the account's balance
                await DatabaseHelper.instance.updateSavingsGoal(updatedGoal);
                setState(() {
                  _savingsGoals.add(updatedGoal);
                });
              } else {
                // No valid account found, just add the goal with the ID
                final retrievedGoal = await DatabaseHelper.instance.getSavingsGoal(goalId);
                if (retrievedGoal != null) {
                  setState(() {
                    _savingsGoals.add(retrievedGoal);
                  });
                }
              }
            } else {
              // No linked account, just add the goal with the ID
              final retrievedGoal = await DatabaseHelper.instance.getSavingsGoal(goalId);
              if (retrievedGoal != null) {
                setState(() {
                  _savingsGoals.add(retrievedGoal);
                });
              }
            }
            
            print('DEBUG: [SavingsPage] Goal added to state, total goals: ${_savingsGoals.length}');
          } catch (e) {
            print('DEBUG: [SavingsPage] Error saving goal: $e');
          }
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
                        onGoalDeleted: (goalId) async {
                          try {
                            // Delete from database first
                            await DatabaseHelper.instance.deleteSavingsGoal(goalId);
                            // Then update UI
                            setState(() {
                              _savingsGoals.removeWhere((g) => g.id == goalId);
                            });
                            print('DEBUG: [SavingsPage] Successfully deleted goal with ID: $goalId');
                          } catch (e) {
                            print('DEBUG: [SavingsPage] Error deleting goal: $e');
                          }
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