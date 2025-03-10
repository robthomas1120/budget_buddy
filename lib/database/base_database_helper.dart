import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class BaseDatabaseHelper {
  static final BaseDatabaseHelper instance = BaseDatabaseHelper._init();
  static sqflite.Database? _database;

  BaseDatabaseHelper._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget_buddy.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqflite.openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        reason TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0.0,
        start_date INTEGER NOT NULL,
        target_date INTEGER NOT NULL,
        account_id INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
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

  Future<void> _upgradeDB(sqflite.Database db, int oldVersion, int newVersion) async {
    print('DEBUG: [BaseDatabaseHelper] Upgrading database from $oldVersion to $newVersion');
    
    // Add savings_goals table if upgrading from version 3
    if (oldVersion < 4 && newVersion >= 4) {
      await db.execute('''
        CREATE TABLE savings_goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          current_amount REAL NOT NULL DEFAULT 0.0,
          start_date INTEGER NOT NULL,
          target_date INTEGER NOT NULL,
          account_id INTEGER,
          FOREIGN KEY (account_id) REFERENCES accounts (id)
        )
      ''');
    }
    
    // Add is_active column to savings_goals table if upgrading from version 4
    if (oldVersion < 5 && newVersion >= 5) {
      try {
        await db.execute('ALTER TABLE savings_goals ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
        print('DEBUG: [BaseDatabaseHelper] Added is_active column to savings_goals table');
      } catch (e) {
        print('DEBUG: [BaseDatabaseHelper] Error adding is_active column: $e');
      }
    }
    
    // Add title column to budgets table if upgrading from version 5
    if (oldVersion < 6 && newVersion >= 6) {
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN title TEXT NOT NULL DEFAULT ""');
        print('DEBUG: [BaseDatabaseHelper] Added title column to budgets table');
      } catch (e) {
        print('DEBUG: [BaseDatabaseHelper] Error adding title column: $e');
      }
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
