// database/database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart' as model;
import '../models/account.dart';

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
      version: 2,
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

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}