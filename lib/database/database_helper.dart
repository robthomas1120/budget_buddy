// lib/database/database_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/transaction.dart' as model;
import '../models/account.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import 'base_database_helper.dart';
import 'helpers/transaction_helper.dart';
import 'helpers/account_helper.dart';
import 'helpers/budget_helper.dart';
import 'helpers/savings_helper.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // Individual helpers
  final TransactionHelper _transactionHelper = TransactionHelper.instance;
  final AccountHelper _accountHelper = AccountHelper.instance;
  final BudgetHelper _budgetHelper = BudgetHelper.instance;
  final SavingsHelper _savingsHelper = SavingsHelper.instance;
  final BaseDatabaseHelper _baseHelper = BaseDatabaseHelper.instance;

  DatabaseHelper._init();

  // Database access
  Future<sqflite.Database> get database async => await _baseHelper.database;

  // Transaction methods
  Future<int> insertTransaction(model.Transaction transaction) => 
      _transactionHelper.insertTransaction(transaction);
      
  Future<model.Transaction?> getTransaction(int id) => 
      _transactionHelper.getTransaction(id);
      
  Future<List<model.Transaction>> getAllTransactions() => 
      _transactionHelper.getAllTransactions();
      
  Future<List<model.Transaction>> getTransactionsByType(String type) => 
      _transactionHelper.getTransactionsByType(type);
      
  Future<List<model.Transaction>> getRecentTransactions(int limit) => 
      _transactionHelper.getRecentTransactions(limit);
      
  Future<List<model.Transaction>> getTransactionsByAccount(int accountId) => 
      _transactionHelper.getTransactionsByAccount(accountId);
      
  Future<List<model.Transaction>> getTransactionsByCategory(String category) => 
      _transactionHelper.getTransactionsByCategory(category);
      
  Future<double> getTotalIncome() => 
      _transactionHelper.getTotalIncome();
      
  Future<double> getTotalExpense() => 
      _transactionHelper.getTotalExpense();
      
  Future<int> updateTransaction(model.Transaction transaction) => 
      _transactionHelper.updateTransaction(transaction);
      
  Future<int> deleteTransaction(int id) => 
      _transactionHelper.deleteTransaction(id);
      
  Future<int> deleteAllTransactions() => 
      _transactionHelper.deleteAllTransactions();

  // Account methods
  Future<int> insertAccount(Account account) => 
      _accountHelper.insertAccount(account);
      
  Future<Account?> getAccount(int id) => 
      _accountHelper.getAccount(id);
      
  Future<List<Account>> getAllAccounts() => 
      _accountHelper.getAllAccounts();
      
  Future<int> updateAccount(Account account) => 
      _accountHelper.updateAccount(account);
      
  Future<int> deleteAccount(int id, {bool deleteLinkedTransactions = false}) => 
      _accountHelper.deleteAccount(id, deleteLinkedTransactions: deleteLinkedTransactions);
      
  Future<double> getTotalBalance() => 
      _accountHelper.getTotalBalance();

  // Budget methods
  Future<int> insertBudget(Budget budget) => 
      _budgetHelper.insertBudget(budget);
      
  Future<Budget?> getBudget(int id) => 
      _budgetHelper.getBudget(id);
      
  Future<List<Budget>> getAllBudgets() => 
      _budgetHelper.getAllBudgets();
      
  Future<List<Budget>> getActiveBudgets() => 
      _budgetHelper.getActiveBudgets();
      
  Future<List<Budget>> getBudgetsByCategory(String category) => 
      _budgetHelper.getBudgetsByCategory(category);
      
  Future<List<Budget>> getBudgetsByAccount(int accountId) => 
      _budgetHelper.getBudgetsByAccount(accountId);
      
  Future<int> updateBudget(Budget budget) => 
      _budgetHelper.updateBudget(budget);
      
  Future<int> deleteBudget(int id) => 
      _budgetHelper.deleteBudget(id);
      
  Future<int> deleteAllBudgets() =>
      _budgetHelper.deleteAllBudgets();
      
  Future<int> renewBudget(Budget budget) => 
      _budgetHelper.renewBudget(budget);
      
  Future<int> resetBudgetSpent(int budgetId) => 
      _budgetHelper.resetBudgetSpent(budgetId);
      
  Future<void> recalculateAllActiveBudgets() => 
      _budgetHelper.recalculateAllActiveBudgets();
      
  Future<List<model.Transaction>> getTransactionsForBudgetPeriod(Budget budget) => 
      _budgetHelper.getTransactionsForBudgetPeriod(budget);

  // Savings Goal methods
  Future<int> insertSavingsGoal(SavingsGoal goal) => 
      _savingsHelper.insertSavingsGoal(goal);
      
  Future<SavingsGoal?> getSavingsGoal(int id) => 
      _savingsHelper.getSavingsGoal(id);
      
  Future<List<SavingsGoal>> getAllSavingsGoals() => 
      _savingsHelper.getAllSavingsGoals();
      
  Future<List<SavingsGoal>> getActiveSavingsGoals() => 
      _savingsHelper.getActiveSavingsGoals();
      
  Future<List<SavingsGoal>> getSavingsGoalsByAccount(int accountId) => 
      _savingsHelper.getSavingsGoalsByAccount(accountId);
      
  Future<int> updateSavingsGoal(SavingsGoal goal) => 
      _savingsHelper.updateSavingsGoal(goal);
      
  Future<int> deleteSavingsGoal(int id) => 
      _savingsHelper.deleteSavingsGoal(id);
      
  Future<int> deleteAllSavingsGoals() =>
      _savingsHelper.deleteAllSavingsGoals();
      
  Future<int> updateSavingsGoalAmount(int id, double amount) => 
      _savingsHelper.updateSavingsGoalAmount(id, amount);
      
  Future<int> toggleSavingsGoalActive(int id, bool isActive) => 
      _savingsHelper.toggleSavingsGoalActive(id, isActive);
      
  Future<void> updateSavingsGoalsFromAccounts({sqflite.Transaction? txn}) => 
      _savingsHelper.updateSavingsGoalsFromAccounts(txn: txn);

  // Close database
  Future close() async => await _baseHelper.close();
}
