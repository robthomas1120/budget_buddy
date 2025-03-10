import 'package:sqflite/sqflite.dart' as sqflite;
import '../../models/budget.dart';
import '../../models/transaction.dart' as model;
import '../base_database_helper.dart';

class BudgetHelper {
  final BaseDatabaseHelper _baseHelper = BaseDatabaseHelper.instance;
  
  // Singleton pattern
  static final BudgetHelper instance = BudgetHelper._init();
  
  BudgetHelper._init();
  
  // Create budget
  Future<int> insertBudget(Budget budget) async {
    final db = await _baseHelper.database;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (hasTitleColumn) {
      // If title column exists, insert with title
      return await db.insert('budgets', budget.toMap());
    } else {
      // If title column doesn't exist, insert without title
      var budgetMap = budget.toMap();
      budgetMap.remove('title'); // Remove title from the map
      
      print('DEBUG: [BudgetHelper] Inserting budget without title field');
      
      // Add title column to budgets table
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table');
        // Now insert with title
        return await db.insert('budgets', budget.toMap());
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column: $e');
        // Insert without title as fallback
        return await db.insert('budgets', budgetMap);
      }
    }
  }

  // Get a budget by ID
  Future<Budget?> getBudget(int id) async {
    final db = await _baseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    final db = await _baseHelper.database;
    final result = await db.query('budgets', orderBy: 'category ASC');
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in getAllBudgets');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in getAllBudgets: $e');
      }
    }
    
    return result.map((map) {
      // If title doesn't exist in the map, use category as title
      if (!map.containsKey('title') || map['title'] == null) {
        map['title'] = map['category'];
      }
      return Budget.fromMap(map);
    }).toList();
  }

  // Get only active budgets
  Future<List<Budget>> getActiveBudgets() async {
    final db = await _baseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in getActiveBudgets');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in getActiveBudgets: $e');
      }
    }
    
    final result = await db.query(
      'budgets',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
      orderBy: 'category ASC'
    );
    
    return result.map((map) {
      // If title doesn't exist in the map, use category as title
      if (!map.containsKey('title') || map['title'] == null) {
        map['title'] = map['category'];
      }
      return Budget.fromMap(map);
    }).toList();
  }

  // Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(String category) async {
    final db = await _baseHelper.database;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in getBudgetsByCategory');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in getBudgetsByCategory: $e');
      }
    }
    
    final result = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'category ASC',
    );
    
    return result.map((map) {
      // If title doesn't exist in the map, use category as title
      if (!map.containsKey('title') || map['title'] == null) {
        map['title'] = map['category'];
      }
      return Budget.fromMap(map);
    }).toList();
  }

  // Get budgets that include a specific account
  Future<List<Budget>> getBudgetsByAccount(int accountId) async {
    final db = await _baseHelper.database;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in getBudgetsByAccount');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in getBudgetsByAccount: $e');
      }
    }
    
    // Using LIKE to find budgets where account_ids contains the accountId
    final result = await db.query(
      'budgets',
      where: 'account_ids LIKE ? OR account_ids IS NULL',
      whereArgs: ['%$accountId%'],
      orderBy: 'category ASC',
    );
    
    return result.map((map) {
      // If title doesn't exist in the map, use category as title
      if (!map.containsKey('title') || map['title'] == null) {
        map['title'] = map['category'];
      }
      
      final budget = Budget.fromMap(map);
      // Double-check if this budget actually includes the account
      // (since our LIKE query might give false positives)
      if (budget.accountIds == null || budget.accountIds!.isEmpty || 
          budget.accountIds!.contains(accountId)) {
        return budget;
      }
      return null;
    }).where((budget) => budget != null).cast<Budget>().toList();
  }

  // Update budget
  Future<int> updateBudget(Budget budget) async {
    final db = await _baseHelper.database;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in updateBudget');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in updateBudget: $e');
      }
    }
    
    var budgetMap = budget.toMap();
    if (!hasTitleColumn) {
      // Remove title from map if column doesn't exist
      budgetMap.remove('title');
    }
    
    return await db.update(
      'budgets',
      budgetMap,
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Delete budget
  Future<int> deleteBudget(int id) async {
    final db = await _baseHelper.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete all budgets
  Future<int> deleteAllBudgets() async {
    final db = await _baseHelper.database;
    return await db.delete('budgets');
  }

  // Generate a new budget period based on an existing budget
  Future<int> renewBudget(Budget budget) async {
    DateTime newStartDate;
    DateTime newEndDate;
    
    if (budget.period == 'weekly') {
      newStartDate = budget.endDate.add(Duration(days: 1));
      newEndDate = newStartDate.add(Duration(days: 6));
    } else { // monthly
      // Get the first day of next month
      final nextMonth = budget.endDate.month == 12 
          ? DateTime(budget.endDate.year + 1, 1, 1)
          : DateTime(budget.endDate.year, budget.endDate.month + 1, 1);
      
      newStartDate = nextMonth;
      
      // Get the last day of that month
      final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      newEndDate = DateTime(nextMonth.year, nextMonth.month, lastDay);
    }
    
    final newBudget = budget.copyWith(
      id: null, // Clear ID to create a new entry
      startDate: newStartDate,
      endDate: newEndDate,
      spent: 0.0, // Reset spent amount
    );
    
    return await insertBudget(newBudget);
  }

  // Reset a budget's spent amount
  Future<int> resetBudgetSpent(int budgetId) async {
    final db = await _baseHelper.database;
    
    // Check if title column exists in budgets table
    var tableInfo = await db.rawQuery("PRAGMA table_info(budgets)");
    bool hasTitleColumn = tableInfo.any((column) => column['name'] == 'title');
    
    if (!hasTitleColumn) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BudgetHelper] Added title column to budgets table in resetBudgetSpent');
      } catch (e) {
        print('DEBUG: [BudgetHelper] Error adding title column in resetBudgetSpent: $e');
      }
    }
    
    return await db.update(
      'budgets',
      {'spent': 0.0},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  // Recalculate budget spending based on transactions
  Future<void> recalculateAllActiveBudgets() async {
    final db = await _baseHelper.database;
    
    // Get all active budgets
    final now = DateTime.now().millisecondsSinceEpoch;
    final activeBudgets = await db.query(
      'budgets',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
    );
    
    print('DEBUG: Found ${activeBudgets.length} active budgets to recalculate');
    
    for (var budgetMap in activeBudgets) {
      final budget = Budget.fromMap(budgetMap);
      print('DEBUG: Recalculating budget ID: ${budget.id}, Category: ${budget.category}');
      
      // Check if this budget has specific accounts
      if (budget.accountIds != null && budget.accountIds!.isNotEmpty) {
        print('DEBUG: Budget has specific accounts: ${budget.accountIds}');
        
        // Build a query to get all expense transactions from these accounts in the budget period
        final accountPlaceholders = budget.accountIds!.map((_) => '?').join(',');
        final whereClause = 'type = ? AND date >= ? AND date <= ? AND account_id IN ($accountPlaceholders)';
        
        final whereArgs = [
          'expense',
          budget.startDate.millisecondsSinceEpoch,
          budget.endDate.millisecondsSinceEpoch,
          ...budget.accountIds!
        ];
        
        // Calculate total spent from transactions
        final expenseResult = await db.rawQuery(
          'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
          whereArgs,
        );
        
        double totalSpent = 0.0;
        if (expenseResult.isNotEmpty && expenseResult.first['total'] != null) {
          totalSpent = (expenseResult.first['total'] as num).toDouble();
        }
        
        print('DEBUG: Calculated spent amount for budget ${budget.id}: $totalSpent (previous: ${budget.spent})');
        
        // Update budget with calculated amount
        await db.update(
          'budgets',
          {'spent': totalSpent},
          where: 'id = ?',
          whereArgs: [budget.id],
        );
        
        print('DEBUG: Updated budget ${budget.id} spent amount to $totalSpent');
      } else {
        // Budget includes all accounts
        print('DEBUG: Budget includes all accounts');
        
        // Get all expense transactions in the budget period
        final whereClause = 'type = ? AND date >= ? AND date <= ?';
        final whereArgs = [
          'expense',
          budget.startDate.millisecondsSinceEpoch,
          budget.endDate.millisecondsSinceEpoch,
        ];
        
        // Calculate total spent from transactions
        final expenseResult = await db.rawQuery(
          'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
          whereArgs,
        );
        
        double totalSpent = 0.0;
        if (expenseResult.isNotEmpty && expenseResult.first['total'] != null) {
          totalSpent = (expenseResult.first['total'] as num).toDouble();
        }
        
        print('DEBUG: Calculated spent amount for budget ${budget.id}: $totalSpent (previous: ${budget.spent})');
        
        // Update budget with calculated amount
        await db.update(
          'budgets',
          {'spent': totalSpent},
          where: 'id = ?',
          whereArgs: [budget.id],
        );
        
        print('DEBUG: Updated budget ${budget.id} spent amount to $totalSpent');
      }
    }
    
    print('DEBUG: Budget recalculation complete');
  }
  
  // Get transactions for a budget period
  Future<List<model.Transaction>> getTransactionsForBudgetPeriod(Budget budget) async {
    final db = await _baseHelper.database;
    String whereClause = 'type = ? AND date >= ? AND date <= ?';
    List<dynamic> whereArgs = [
      'expense',  
      budget.startDate.millisecondsSinceEpoch, 
      budget.endDate.millisecondsSinceEpoch
    ];
    
    // If the budget is for specific accounts, add that to the query
    if (budget.accountIds != null && budget.accountIds!.isNotEmpty) {
      whereClause += ' AND account_id IN (${budget.accountIds!.map((_) => '?').join(',')})';
      whereArgs.addAll(budget.accountIds!);
    }
    
    final result = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }
  
  // Helper method to adjust budgets when a transaction is updated
  Future<void> adjustBudgetsForTransaction(
    sqflite.Transaction txn,
    int? accountId,
    String category,
    double amountChange
  ) async {
    print('DEBUG: [BudgetHelper] Adjusting budgets for transaction');
    print('DEBUG: [BudgetHelper] - Category: $category');
    print('DEBUG: [BudgetHelper] - Account ID: $accountId');
    print('DEBUG: [BudgetHelper] - Amount Change: $amountChange');
    
    // If no account ID, we can't update any account-specific budgets
    if (accountId == null) {
      print('DEBUG: [BudgetHelper] No account ID provided, skipping budget updates');
      return;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Get all active budgets, regardless of category
    final activeBudgets = await txn.query(
      'budgets',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
    );
    
    print('DEBUG: Found ${activeBudgets.length} active budgets');
    
    for (var budgetMap in activeBudgets) {
      final budget = Budget.fromMap(budgetMap);
      print('DEBUG: [BudgetHelper] Processing budget ID: ${budget.id}, Category: ${budget.category}');
      
      // Check if this transaction's account is included in the budget
      bool shouldInclude = false;
      
      // If no specific accounts are set for the budget, include all accounts
      if (budget.accountIds == null || budget.accountIds!.isEmpty) {
        print('DEBUG: [BudgetHelper] Budget includes all accounts - skipping (requires specific accounts)');
        continue; // Skip budgets that don't have specific accounts
      } 
      // If account IDs are specified, only include if the transaction's account is in the list
      else if (budget.accountIds!.contains(accountId)) {
        shouldInclude = true;
        print('DEBUG: [BudgetHelper] Budget includes account ID: $accountId');
      } else {
        print('DEBUG: [BudgetHelper] Budget does not include account ID: $accountId');
        continue;
      }
      
      if (shouldInclude) {
        // Get current spent amount to ensure we're working with latest data
        final currentBudgetData = await txn.query(
          'budgets',
          columns: ['spent'],
          where: 'id = ?',
          whereArgs: [budget.id],
        );
        
        final currentSpent = currentBudgetData.first['spent'] as double;
        final newSpent = currentSpent + amountChange;
        
        print('DEBUG: [BudgetHelper] Updating budget ${budget.id}: current spent: $currentSpent, new spent: $newSpent');
        
        await txn.update(
          'budgets',
          {'spent': newSpent > 0 ? newSpent : 0}, // Ensure spent doesn't go negative
          where: 'id = ?',
          whereArgs: [budget.id],
        );
        
        print('DEBUG: [BudgetHelper] Budget ${budget.id} updated successfully');
      }
    }
  }
}
