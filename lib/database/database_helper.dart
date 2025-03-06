//database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart' as model;

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
      version: 1,
      onCreate: _createDB,
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
        notes TEXT
      )
    ''');
  }

  // CRUD Operations
  
  // Create
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Read
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

  Future<List<model.Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await instance.database;
    
    // Create date range for the month
    final startDate = DateTime(year, month, 1);
    final endDate = month < 12
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
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

  // Update
  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTransactions() async {
    final db = await instance.database;
    return await db.delete('transactions');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}