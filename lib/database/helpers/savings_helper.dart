import 'package:sqflite/sqflite.dart' as sqflite;
import '../../models/savings_goal.dart';
import '../base_database_helper.dart';

class SavingsHelper {
  final BaseDatabaseHelper _baseHelper = BaseDatabaseHelper.instance;
  
  // Singleton pattern
  static final SavingsHelper instance = SavingsHelper._init();
  
  SavingsHelper._init();
  
  // Create savings goal
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await _baseHelper.database;
    return await db.insert('savings_goals', goal.toMap());
  }
  
  // Read savings goals
  Future<SavingsGoal?> getSavingsGoal(int id) async {
    final db = await _baseHelper.database;
    final maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavingsGoal.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await _baseHelper.database;
    final result = await db.query('savings_goals', orderBy: 'name ASC');
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }
  
  Future<List<SavingsGoal>> getActiveSavingsGoals() async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'savings_goals',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }
  
  Future<List<SavingsGoal>> getSavingsGoalsByAccount(int accountId) async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'savings_goals',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'name ASC',
    );
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }
  
  // Update savings goal
  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await _baseHelper.database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
  
  // Delete savings goal
  Future<int> deleteSavingsGoal(int id) async {
    final db = await _baseHelper.database;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete all savings goals
  Future<int> deleteAllSavingsGoals() async {
    final db = await _baseHelper.database;
    return await db.delete('savings_goals');
  }
  
  // Update current amount for a savings goal
  Future<int> updateSavingsGoalAmount(int id, double amount) async {
    final db = await _baseHelper.database;
    return await db.update(
      'savings_goals',
      {'current_amount': amount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mark a savings goal as completed or active
  Future<int> toggleSavingsGoalActive(int id, bool isActive) async {
    final db = await _baseHelper.database;
    return await db.update(
      'savings_goals',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Update savings goals from linked accounts
  Future<void> updateSavingsGoalsFromAccounts({sqflite.Transaction? txn}) async {
    final db = await _baseHelper.database;
    
    // Use provided transaction or start a new one
    final transaction = txn ?? await db;
    
    // Get all savings goals with linked accounts
    final savingsGoals = await transaction.query(
      'savings_goals',
      where: 'account_id IS NOT NULL',
    );
    
    print('DEBUG: [SavingsHelper] Updating ${savingsGoals.length} savings goals with linked accounts');
    
    for (var goalMap in savingsGoals) {
      final goal = SavingsGoal.fromMap(goalMap);
      
      if (goal.accountId != null) {
        // Get the current account balance
        final accountResult = await transaction.query(
          'accounts',
          columns: ['balance'],
          where: 'id = ?',
          whereArgs: [goal.accountId],
        );
        
        if (accountResult.isNotEmpty) {
          double accountBalance = accountResult.first['balance'] as double;
          
          // Update the savings goal's current amount to match the account balance
          await transaction.update(
            'savings_goals',
            {'current_amount': accountBalance},
            where: 'id = ?',
            whereArgs: [goal.id],
          );
          
          print('DEBUG: [SavingsHelper] Updated savings goal ${goal.id} amount to $accountBalance');
          
          // If the goal is reached, mark it as inactive if not already
          if (accountBalance >= goal.targetAmount && goal.isActive) {
            await transaction.update(
              'savings_goals',
              {'is_active': 0},
              where: 'id = ?',
              whereArgs: [goal.id],
            );
            print('DEBUG: [SavingsHelper] Marked savings goal ${goal.id} as completed (target reached)');
          }
        }
      }
    }
  }
}
