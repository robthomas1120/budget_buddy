import * as SQLite from 'expo-sqlite';
import { Account } from '../types';

export const insertAccount = async (db: SQLite.SQLiteDatabase, account: Account) => {
    const result = await db.runAsync(
        `INSERT INTO accounts (name, type, icon_name, balance) VALUES (?, ?, ?, ?)`,
        [account.name, account.type, account.iconName || null, account.balance]
    );
    return result.lastInsertRowId;
};

export const getAccounts = async (db: SQLite.SQLiteDatabase): Promise<Account[]> => {
    const result = await db.getAllAsync<any>('SELECT * FROM accounts');
    return result.map(row => ({
        id: row.id,
        name: row.name,
        type: row.type,
        iconName: row.icon_name,
        balance: row.balance,
    }));
};

export const updateAccount = async (db: SQLite.SQLiteDatabase, account: Account) => {
    if (!account.id) throw new Error("Account ID is required for update");

    await db.runAsync(
        `UPDATE accounts SET name = ?, type = ?, icon_name = ?, balance = ? WHERE id = ?`,
        [account.name, account.type, account.iconName || null, account.balance, account.id]
    );
};

export const deleteAccount = async (db: SQLite.SQLiteDatabase, id: number) => {
    await db.runAsync('DELETE FROM accounts WHERE id = ?', [id]);
};

export const getAccountById = async (db: SQLite.SQLiteDatabase, id: number): Promise<Account | null> => {
    const row = await db.getFirstAsync<any>('SELECT * FROM accounts WHERE id = ?', [id]);
    if (!row) return null;
    return {
        id: row.id,
        name: row.name,
        type: row.type,
        iconName: row.icon_name,
        balance: row.balance,
    };
};
