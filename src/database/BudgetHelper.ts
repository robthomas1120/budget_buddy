import * as SQLite from 'expo-sqlite';
import { Budget } from '../types';

export const insertBudget = async (db: SQLite.SQLiteDatabase, budget: Budget) => {
    const accountIdsStr = budget.accountIds ? budget.accountIds.join(',') : null;
    const isActive = budget.isActive ? 1 : 0;
    const result = await db.runAsync(
        `INSERT INTO budgets (title, category, amount, period, start_date, end_date, spent, account_ids, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            budget.title,
            budget.category,
            budget.amount,
            budget.period,
            budget.startDate,
            budget.endDate,
            budget.spent,
            accountIdsStr,
            isActive
        ]
    );
    return result.lastInsertRowId;
};

export const getBudgets = async (db: SQLite.SQLiteDatabase): Promise<Budget[]> => {
    const result = await db.getAllAsync<any>(`
        SELECT b.*, 
        COALESCE((SELECT SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) 
                  FROM transactions t 
                  WHERE t.budget_id = b.id), 0) as balance 
        FROM budgets b
    `);
    return result.map(row => ({
        id: row.id,
        title: row.title,
        category: row.category,
        amount: row.amount,
        period: row.period,
        startDate: row.start_date,
        endDate: row.end_date,
        spent: row.balance, // Re-purpose 'spent' as 'balance'
        accountIds: row.account_ids ? row.account_ids.split(',').map(Number) : [],
        isActive: row.is_active === 1
    }));
};

export const updateBudget = async (db: SQLite.SQLiteDatabase, budget: Budget) => {
    if (!budget.id) throw new Error("Budget ID is required for update");
    const accountIdsStr = budget.accountIds ? budget.accountIds.join(',') : null;
    const isActive = budget.isActive ? 1 : 0;

    await db.runAsync(
        `UPDATE budgets SET title = ?, category = ?, amount = ?, period = ?, start_date = ?, end_date = ?, spent = ?, account_ids = ?, is_active = ? WHERE id = ?`,
        [
            budget.title,
            budget.category,
            budget.amount,
            budget.period,
            budget.startDate,
            budget.endDate,
            budget.spent,
            accountIdsStr,
            isActive,
            budget.id
        ]
    );
};

export const deleteBudget = async (db: SQLite.SQLiteDatabase, id: number) => {
    await db.runAsync('DELETE FROM budgets WHERE id = ?', [id]);
};
