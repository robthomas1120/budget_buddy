import * as SQLite from 'expo-sqlite';
import { SavingsGoal } from '../types';

export const insertSavingsGoal = async (db: SQLite.SQLiteDatabase, goal: SavingsGoal) => {
    const result = await db.runAsync(
        `INSERT INTO savings_goals (name, reason, target_amount, current_amount, start_date, target_date, account_id, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            goal.name,
            goal.reason || null,
            goal.targetAmount,
            goal.currentAmount,
            goal.startDate,
            goal.targetDate,
            goal.accountId || null,
            goal.isActive ? 1 : 0
        ]
    );
    return result.lastInsertRowId;
};

export const getSavingsGoals = async (db: SQLite.SQLiteDatabase): Promise<SavingsGoal[]> => {
    const result = await db.getAllAsync<any>('SELECT * FROM savings_goals');
    return result.map(row => ({
        id: row.id,
        name: row.name,
        reason: row.reason,
        targetAmount: row.target_amount,
        currentAmount: row.current_amount,
        startDate: row.start_date,
        targetDate: row.target_date,
        accountId: row.account_id,
        isActive: row.is_active === 1,
    }));
};

export const updateSavingsGoal = async (db: SQLite.SQLiteDatabase, goal: SavingsGoal) => {
    if (!goal.id) throw new Error("Savings Goal ID is required for update");

    await db.runAsync(
        `UPDATE savings_goals SET name = ?, reason = ?, target_amount = ?, current_amount = ?, start_date = ?, target_date = ?, account_id = ?, is_active = ? WHERE id = ?`,
        [
            goal.name,
            goal.reason || null,
            goal.targetAmount,
            goal.currentAmount,
            goal.startDate,
            goal.targetDate,
            goal.accountId || null,
            goal.isActive ? 1 : 0,
            goal.id
        ]
    );
};

export const deleteSavingsGoal = async (db: SQLite.SQLiteDatabase, id: number) => {
    await db.runAsync('DELETE FROM savings_goals WHERE id = ?', [id]);
};
