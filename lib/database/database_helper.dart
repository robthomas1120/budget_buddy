// lib/database/database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart' as model;
import '../models/account.dart';
import '../models/budget.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increased version to 3 for budget table
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        account_id INTEGER,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_name TEXT,
        balance REAL NOT NULL
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        spent REAL NOT NULL DEFAULT 0.0,
        account_ids TEXT
      )
    ''');

    // Create a default account for existing users
    await db.insert('accounts', {
      'name': 'Cash',
      'type': 'cash',
      'icon_name': 'wallet',
      'balance': 0.0,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add account_id column to transactions table if upgrading from version 1
      await db.execute('ALTER TABLE transactions ADD COLUMN account_id INTEGER');
      
      // Create accounts table
      await db.execute('''
        CREATE TABLE accounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon_name TEXT,
          balance REAL NOT NULL
        )
      ''');

      // Create a default account and set the balance based on existing transactions
      final defaultAccountId = await db.insert('accounts', {
        'name': 'Cash',
        'type': 'cash',
        'icon_name': 'wallet',
        'balance': 0.0,
      });

      // Calculate the current balance from existing transactions
      final incomeResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
        ['income'],
      );
      final expenseResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
        ['expense'],
      );
      
      final totalIncome = incomeResult.isNotEmpty && incomeResult.first['total'] != null
          ? (incomeResult.first['total'] as num).toDouble()
          : 0.0;
      
      final totalExpense = expenseResult.isNotEmpty && expenseResult.first['total'] != null
          ? (expenseResult.first['total'] as num).toDouble()
          : 0.0;

      final balance = totalIncome - totalExpense;

      // Update the default account with the calculated balance
      await db.update(
        'accounts',
        {'balance': balance},
        where: 'id = ?',
        whereArgs: [defaultAccountId],
      );

      // Link all existing transactions to the default account
      await db.update(
        'transactions',
        {'account_id': defaultAccountId},
        where: 'account_id IS NULL',
      );
    }

    if (oldVersion < 3) {
      // Add budgets table in version 3
      await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          period TEXT NOT NULL,
          start_date INTEGER NOT NULL,
          end_date INTEGER NOT NULL,
          spent REAL NOT NULL DEFAULT 0.0,
          account_ids TEXT
        )
      ''');
    }
  }

  // CRUD Operations for Transactions
  
  // Create
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    
    // Start a transaction to ensure data consistency
    return await db.transaction((txn) async {
      // Insert the transaction record
      final transactionId = await txn.insert('transactions', transaction.toMap());
      
      // If accountId is provided, update the account balance
      if (transaction.accountId != null) {
        // Get the current account balance
        final accountResult = await txn.query(
          'accounts',
          columns: ['balance'],
          where: 'id = ?',
          whereArgs: [transaction.accountId],
        );
        
        if (accountResult.isNotEmpty) {
          double currentBalance = accountResult.first['balance'] as double;
          double newBalance = currentBalance;
          
          // Add or subtract based on transaction type
          if (transaction.type == 'income') {
            newBalance += transaction.amount;
          } else if (transaction.type == 'expense') {
            newBalance -= transaction.amount;
            
            // Update any active budgets that match this transaction's category
            final now = DateTime.now().millisecondsSinceEpoch;
            
            // Debug log - uncomment for troubleshooting
            // print('Transaction created: ${transaction.title} - ${transaction.category} - ${transaction.amount}');
            
            final activeBudgets = await txn.query(
              'budgets',
              where: 'category = ? AND start_date <= ? AND end_date >= ?',
              whereArgs: [transaction.category, now, now],
            );
            
            // Debug log - uncomment for troubleshooting
            // print('Found active budgets: ${activeBudgets.length}');
            
            for (var budgetMap in activeBudgets) {
              final budget = Budget.fromMap(budgetMap);
              
              // Check if this transaction's account is included in the budget
              bool shouldInclude = false;
              
              // If no specific accounts are set, include all accounts
              if (budget.accountIds == null || budget.accountIds!.isEmpty) {
                shouldInclude = true;
                // Debug log - uncomment for troubleshooting
                // print('Budget includes all accounts');
              } 
              // Include only if the transaction's account is in the budget's accounts
              else if (transaction.accountId != null && 
                       budget.accountIds!.contains(transaction.accountId)) {
                shouldInclude = true;
                // Debug log - uncomment for troubleshooting
                // print('Budget includes account ${transaction.accountId}');
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
                final newSpent = currentSpent + transaction.amount;
                
                // Debug log - uncomment for troubleshooting
                // print('Updating budget ${budget.id}: current spent: $currentSpent, new spent: $newSpent');
                
                await txn.update(
                  'budgets',
                  {'spent': newSpent},
                  where: 'id = ?',
                  whereArgs: [budget.id],
                );
              }
            }
          }
          
          // Update the account balance
          await txn.update(
            'accounts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [transaction.accountId],
          );
        }
      }
      
      return transactionId;
    });
  }

  // Read transactions
  Future<model.Transaction?> getTransaction(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return model.Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getRecentTransactions(int limit) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsForBudgetPeriod(Budget budget) async {
    final db = await instance.database;
    String whereClause = 'type = ? AND category = ? AND date >= ? AND date <= ?';
    List<dynamic> whereArgs = [
      'expense', 
      budget.category, 
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

  // Get sum of amounts by type
  Future<double> getTotalIncome() async {
    return await _getSumByType('income');
  }

  Future<double> getTotalExpense() async {
    return await _getSumByType('expense');
  }

  Future<double> _getSumByType(String type) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    
    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // Update transaction
  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    
    return await db.transaction((txn) async {
      // First get the original transaction to calculate balance change
      final originalTransResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      if (originalTransResult.isEmpty) {
        return 0; // Transaction not found
      }
      
      final originalTrans = model.Transaction.fromMap(originalTransResult.first);
      
      // Update the transaction
      final updateResult = await txn.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      // If account ID has changed or amount has changed, update account balances
      if (transaction.accountId != null) {
        // If account has changed, handle both old and new accounts
        if (originalTrans.accountId != transaction.accountId && originalTrans.accountId != null) {
          // Adjust old account balance
          await _adjustAccountBalance(
            txn,
            originalTrans.accountId!,
            originalTrans.type == 'income' ? -originalTrans.amount : originalTrans.amount,
          );
          
          // Adjust new account balance
          await _adjustAccountBalance(
            txn,
            transaction.accountId!,
            transaction.type == 'income' ? transaction.amount : -transaction.amount,
          );
        } else {
          // Same account, just adjust the difference
          double balanceChange = 0.0;
          
          if (transaction.type == 'income') {
            balanceChange = transaction.amount - originalTrans.amount;
          } else {
            balanceChange = originalTrans.amount - transaction.amount;
          }
          
          await _adjustAccountBalance(txn, transaction.accountId!, balanceChange);
        }
      }
      
      // Update budgets if this is an expense and category or amount has changed
      if (transaction.type == 'expense') {
        // If the category changed, we need to update budgets for both categories
        if (originalTrans.category != transaction.category) {
          // First, adjust any budgets that had the old category
          await _adjustBudgetsForTransaction(
            txn, 
            originalTrans.accountId, 
            originalTrans.category, 
            -originalTrans.amount
          );
          
          // Then, adjust any budgets for the new category
          await _adjustBudgetsForTransaction(
            txn, 
            transaction.accountId, 
            transaction.category, 
            transaction.amount
          );
        } 
        // If only the amount changed but category remained the same
        else if (originalTrans.amount != transaction.amount) {
          double amountDifference = transaction.amount - originalTrans.amount;
          await _adjustBudgetsForTransaction(
            txn, 
            transaction.accountId, 
            transaction.category, 
            amountDifference
          );
        }
      }
      
      return updateResult;
    });
  }

  // Helper method to adjust account balance
  Future<void> _adjustAccountBalance(Transaction txn, int accountId, double amount) async {
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

  // Helper method to adjust budgets when a transaction is updated
  Future<void> _adjustBudgetsForTransaction(
    Transaction txn,
    int? accountId,
    String category,
    double amountChange
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final activeBudgets = await txn.query(
      'budgets',
      where: 'category = ? AND start_date <= ? AND end_date >= ?',
      whereArgs: [category, now, now],
    );
    
    for (var budgetMap in activeBudgets) {
      final budget = Budget.fromMap(budgetMap);
      
      // Check if this transaction's account is included in the budget
      bool shouldInclude = false;
      if (budget.accountIds == null || budget.accountIds!.isEmpty) {
        // If no specific accounts are set, include all accounts
        shouldInclude = true;
      } else if (accountId != null && budget.accountIds!.contains(accountId)) {
        // Include only if the transaction's account is in the budget's accounts
        shouldInclude = true;
      }
      
      if (shouldInclude) {
        final newSpent = budget.spent + amountChange;
        await txn.update(
          'budgets',
          {'spent': newSpent > 0 ? newSpent : 0}, // Ensure spent doesn't go negative
          where: 'id = ?',
          whereArgs: [budget.id],
        );
      }
    }
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    
    return await db.transaction((txn) async {
      // First get the transaction to adjust the account balance
      final transResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (transResult.isEmpty) {
        return 0; // Transaction not found
      }
      
      final trans = model.Transaction.fromMap(transResult.first);
      
      // Adjust account balance if applicable
      if (trans.accountId != null) {
        await _adjustAccountBalance(
          txn,
          trans.accountId!,
          trans.type == 'income' ? -trans.amount : trans.amount,
        );
      }
      
      // If this is an expense, also adjust the budget(s)
      if (trans.type == 'expense') {
        await _adjustBudgetsForTransaction(
          txn,
          trans.accountId,
          trans.category,
          -trans.amount // Subtract the amount from the budget
        );
      }
      
      // Delete the transaction
      return await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Delete all transactions
  Future<int> deleteAllTransactions() async {
    final db = await instance.database;
    
    // Start a transaction to ensure data consistency
    return await db.transaction((txn) async {
      // Reset all account balances to zero
      await txn.update(
        'accounts',
        {'balance': 0.0},
      );
      
      // Reset all budget spent amounts to zero
      await txn.update(
        'budgets',
        {'spent': 0.0},
      );
      
      // Delete all transactions
      return await txn.delete('transactions');
    });
  }

  // CRUD Operations for Accounts
  
  // Create account
  Future<int> insertAccount(Account account) async {
    final db = await instance.database;
    return await db.insert('accounts', account.toMap());
  }
  
  // Read accounts
  Future<Account?> getAccount(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<Account>> getAllAccounts() async {
    final db = await instance.database;
    final result = await db.query('accounts', orderBy: 'name ASC');
    return result.map((map) => Account.fromMap(map)).toList();
  }
  
  // Update account
  Future<int> updateAccount(Account account) async {
    final db = await instance.database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
  
  // Delete account
  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    // First check if there are any transactions linked to this account
    final transCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE account_id = ?',
      [id],
    ));
    
    if (transCount != null && transCount > 0) {
      throw Exception('Cannot delete account with linked transactions');
    }
    
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Get total balance across all accounts
  Future<double> getTotalBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM accounts',
    );
    
    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // CRUD Operations for Budgets
  
  // Create budget
  Future<int> insertBudget(Budget budget) async {
    final db = await instance.database;
    return await db.insert('budgets', budget.toMap());
  }

  // Get a budget by ID
  Future<Budget?> getBudget(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    final result = await db.query('budgets', orderBy: 'end_date DESC');
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  // Get active budgets
  Future<List<Budget>> getActiveBudgets() async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = await db.query(
      'budgets',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
      orderBy: 'end_date ASC',
    );
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  // Get budgets by category
  Future<List<Budget>> getBudgetsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'end_date DESC',
    );
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  // Get budgets that include a specific account
  Future<List<Budget>> getBudgetsByAccount(int accountId) async {
    final db = await instance.database;
    // Using LIKE to find budgets where account_ids contains the accountId
    final result = await db.query(
      'budgets',
      where: 'account_ids LIKE ? OR account_ids IS NULL',
      whereArgs: ['%$accountId%'],
      orderBy: 'end_date DESC',
    );
    
    return result.map((map) {
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
    final db = await instance.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Delete budget
  Future<int> deleteBudget(int id) async {
    final db = await instance.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
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
    final db = await instance.database;
    return await db.update(
      'budgets',
      {'spent': 0.0},
      where: 'id = ?',
      whereArgs: [budgetId],
    );
  }

  // Recalculate budget spending based on transactions
  Future<void> recalculateAllActiveBudgets() async {
    final db = await instance.database;
    
    // Get all active budgets
    final now = DateTime.now().millisecondsSinceEpoch;
    final activeBudgets = await db.query(
      'budgets',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
    );
    
    for (var budgetMap in activeBudgets) {
      final budget = Budget.fromMap(budgetMap);
      
      // Get all relevant transactions for this budget period and category
      String whereClause = 'type = ? AND category = ? AND date >= ? AND date <= ?';
      List<dynamic> whereArgs = [
        'expense', 
        budget.category, 
        budget.startDate.millisecondsSinceEpoch, 
        budget.endDate.millisecondsSinceEpoch
      ];
      
      // If the budget is for specific accounts, add that to the query
      if (budget.accountIds != null && budget.accountIds!.isNotEmpty) {
        final accountPlaceholders = budget.accountIds!.map((_) => '?').join(',');
        whereClause += ' AND account_id IN ($accountPlaceholders)';
        whereArgs.addAll(budget.accountIds!);
      }
      
      // Calculate total spent from transactions
      final expenseResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
        whereArgs,
      );
      
      double totalSpent = 0.0;
      if (expenseResult.isNotEmpty && expenseResult.first['total'] != null) {
        totalSpent = (expenseResult.first['total'] as num).toDouble();
      }
      
      // Update budget with calculated amount
      await db.update(
        'budgets',
        {'spent': totalSpent},
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}