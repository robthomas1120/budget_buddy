import 'package:sqflite/sqflite.dart' as sqflite;
import '../../models/account.dart';
import '../../models/budget.dart';
import '../base_database_helper.dart';

class AccountHelper {
  final BaseDatabaseHelper _baseHelper = BaseDatabaseHelper.instance;
  
  // Singleton pattern
  static final AccountHelper instance = AccountHelper._init();
  
  AccountHelper._init();
  
  // Create account
  Future<int> insertAccount(Account account) async {
    final db = await _baseHelper.database;
    return await db.insert('accounts', account.toMap());
  }
  
  // Read accounts
  Future<Account?> getAccount(int id) async {
    final db = await _baseHelper.database;
    
    // Use a transaction to prevent database locking
    final maps = await db.transaction((txn) async {
      return await txn.query(
        'accounts',
        where: 'id = ?',
        whereArgs: [id],
      );
    });

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<Account>> getAllAccounts() async {
    final db = await _baseHelper.database;
    print('DEBUG: [AccountHelper] Getting all accounts');
    
    // Use a dedicated transaction to prevent database locking
    final result = await db.transaction((txn) async {
      return await txn.query('accounts', orderBy: 'name ASC');
    });
    
    final accounts = result.map((map) => Account.fromMap(map)).toList();
    print('DEBUG: [AccountHelper] Retrieved ${accounts.length} accounts');
    
    // Log the balance of each account
    for (var account in accounts) {
      print('DEBUG: [AccountHelper] Account ${account.id}: ${account.name} - Balance: ${account.balance}');
    }
    
    return accounts;
  }
  
  // Update account
  Future<int> updateAccount(Account account) async {
    final db = await _baseHelper.database;
    
    // Use a transaction to prevent database locking
    return await db.transaction((txn) async {
      return await txn.update(
        'accounts',
        account.toMap(),
        where: 'id = ?',
        whereArgs: [account.id],
      );
    });
  }
  
  // Delete account
  Future<int> deleteAccount(int id, {bool deleteLinkedTransactions = false}) async {
    final db = await _baseHelper.database;
    
    // First check if there are any transactions linked to this account
    final transCount = sqflite.Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE account_id = ?',
      [id],
    ));
    
    if (transCount != null && transCount > 0) {
      if (deleteLinkedTransactions) {
        // Delete linked transactions if requested
        await db.delete(
          'transactions',
          where: 'account_id = ?',
          whereArgs: [id],
        );
        print('DEBUG: [AccountHelper] Deleted $transCount transactions linked to account $id');
      } else {
        throw Exception('Cannot delete account with linked transactions');
      }
    }
    
    // Check if there are any savings goals linked to this account
    final goalsCount = sqflite.Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM savings_goals WHERE account_id = ?',
      [id],
    ));
    
    if (goalsCount != null && goalsCount > 0) {
      // Unlink the savings goals from this account
      await db.update(
        'savings_goals',
        {'account_id': null},
        where: 'account_id = ?',
        whereArgs: [id],
      );
      print('DEBUG: [AccountHelper] Unlinked $goalsCount savings goals from account $id');
    }
    
    // Check if there are any budgets linked to this account
    final budgetsWithAccount = await db.query(
      'budgets',
      where: 'account_ids LIKE ?',
      whereArgs: ['%$id%'],
    );
    
    if (budgetsWithAccount.isNotEmpty) {
      print('DEBUG: [AccountHelper] Found ${budgetsWithAccount.length} budgets linked to account $id');
      
      // Update each budget to remove this account ID
      for (var budgetMap in budgetsWithAccount) {
        final budget = Budget.fromMap(budgetMap);
        if (budget.accountIds != null && budget.accountIds!.contains(id)) {
          final updatedAccountIds = budget.accountIds!.where((accId) => accId != id).toList();
          
          await db.update(
            'budgets',
            {'account_ids': updatedAccountIds.isEmpty ? null : updatedAccountIds.join(',')},
            where: 'id = ?',
            whereArgs: [budget.id],
          );
          print('DEBUG: [AccountHelper] Removed account $id from budget ${budget.id}');
        }
      }
    }
    
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Get total balance across all accounts
  Future<double> getTotalBalance() async {
    final db = await _baseHelper.database;
    print('DEBUG: [AccountHelper] Getting total balance across all accounts');
    
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM accounts',
    );
    
    double total = result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
        
    print('DEBUG: [AccountHelper] Total balance: $total');
    return total;
  }
  
  // Helper method to adjust account balance - used internally and by TransactionHelper
  Future<void> adjustAccountBalance(sqflite.Transaction txn, int accountId, double amount) async {
    final accountResult = await txn.query(
      'accounts',
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [accountId],
    );
    
    if (accountResult.isNotEmpty) {
      double currentBalance = accountResult.first['balance'] as double;
      double newBalance = currentBalance + amount;
      
      await txn.update(
        'accounts',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [accountId],
      );
    }
  }
}
