import * as SQLite from 'expo-sqlite';
import { Transaction } from '../types';

export const insertTransaction = async (db: SQLite.SQLiteDatabase, transaction: Transaction) => {
    const result = await db.runAsync(
        `INSERT INTO transactions (title, amount, type, category, date, notes, account_id, budget_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            transaction.title,
            transaction.amount,
            transaction.type,
            transaction.category,
            transaction.date,
            transaction.notes || null,
            transaction.accountId || null,
            transaction.budgetId || null,
        ]
    );
    return result.lastInsertRowId;
};

export const getTransactions = async (db: SQLite.SQLiteDatabase): Promise<Transaction[]> => {
    const result = await db.getAllAsync<any>('SELECT * FROM transactions ORDER BY date DESC');
    return result.map(row => ({
        id: row.id,
        title: row.title,
        amount: row.amount,
        type: row.type,
        category: row.category,
        date: row.date,
        notes: row.notes,
        accountId: row.account_id,
        budgetId: row.budget_id,
    }));
};

export const updateTransaction = async (db: SQLite.SQLiteDatabase, transaction: Transaction) => {
    if (!transaction.id) throw new Error("Transaction ID is required for update");

    await db.runAsync(
        `UPDATE transactions SET title = ?, amount = ?, type = ?, category = ?, date = ?, notes = ?, account_id = ?, budget_id = ? WHERE id = ?`,
        [
            transaction.title,
            transaction.amount,
            transaction.type,
            transaction.category,
            transaction.date,
            transaction.notes || null,
            transaction.accountId || null,
            transaction.budgetId || null,
            transaction.id
        ]
    );
};

export const deleteTransaction = async (db: SQLite.SQLiteDatabase, id: number) => {
    await db.runAsync('DELETE FROM transactions WHERE id = ?', [id]);
};
