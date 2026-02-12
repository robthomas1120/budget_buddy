import * as SQLite from 'expo-sqlite';
import { Transaction, Account, Budget, SavingsGoal } from '../types';

const DB_NAME = 'budget_buddy.db';

export const getDBConnection = async () => {
  return await SQLite.openDatabaseAsync(DB_NAME);
};

export const createTables = async (db: SQLite.SQLiteDatabase) => {
  // Create transactions table
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      date INTEGER NOT NULL,
      notes TEXT,
      account_id INTEGER,
      budget_id INTEGER,
      FOREIGN KEY (account_id) REFERENCES accounts (id),
      FOREIGN KEY (budget_id) REFERENCES budgets (id)
    );
  `);

  // Create accounts table
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      icon_name TEXT,
      balance REAL NOT NULL
    );
  `);

  // Create savings_goals table
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS savings_goals (
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
    );
  `);

  // Create budgets table
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      period TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER NOT NULL,
      spent REAL NOT NULL DEFAULT 0.0,
      account_ids TEXT,
      is_active INTEGER NOT NULL DEFAULT 1
    );
  `);
};

export const seedDatabase = async (db: SQLite.SQLiteDatabase) => {
  const result = await db.getFirstAsync<{ count: number }>(
    'SELECT COUNT(*) as count FROM accounts'
  );

  if (result && result.count === 0) {
    await db.runAsync(
      'INSERT INTO accounts (name, type, icon_name, balance) VALUES (?, ?, ?, ?)',
      ['Cash', 'cash', 'wallet', 0.0]
    );
    console.log('Database seeded with default account');
  }
};

export const initDatabase = async () => {
  try {
    const db = await getDBConnection();
    await createTables(db);

    // Migration: Add budget_id to transactions if it doesn't exist
    try {
      await db.execAsync('ALTER TABLE transactions ADD COLUMN budget_id INTEGER REFERENCES budgets(id);');
      console.log('Migration: Added budget_id to transactions');
    } catch (e) {
      // Column likely already exists
    }

    await seedDatabase(db);
    return db;
  } catch (error) {
    console.error('Error initializing database', error);
    throw error;
  }
};
