import React, { createContext, useContext, useEffect, useState } from 'react';
import * as SQLite from 'expo-sqlite';
import { initDatabase } from '../database/DatabaseHelper';
import { getTransactions } from '../database/TransactionHelper';
import { getAccounts } from '../database/AccountHelper';
import { getBudgets } from '../database/BudgetHelper';
import { getSavingsGoals } from '../database/SavingsHelper';
import { Transaction, Account, Budget, SavingsGoal } from '../types';

interface AppContextType {
    db: SQLite.SQLiteDatabase | null;
    transactions: Transaction[];
    accounts: Account[];
    budgets: Budget[];
    savingsGoals: SavingsGoal[];
    loading: boolean;
    refreshData: () => Promise<void>;
    refreshTransactions: () => Promise<void>;
    refreshAccounts: () => Promise<void>;
    refreshBudgets: () => Promise<void>;
    refreshSavingsGoals: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [db, setDb] = useState<SQLite.SQLiteDatabase | null>(null);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [accounts, setAccounts] = useState<Account[]>([]);
    const [budgets, setBudgets] = useState<Budget[]>([]);
    const [savingsGoals, setSavingsGoals] = useState<SavingsGoal[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadData = async () => {
            try {
                const database = await initDatabase();
                setDb(database);

                // Load initial data
                const [txs, accs, bgs, sgs] = await Promise.all([
                    getTransactions(database),
                    getAccounts(database),
                    getBudgets(database),
                    getSavingsGoals(database)
                ]);

                setTransactions(txs);
                setAccounts(accs);
                setBudgets(bgs);
                setSavingsGoals(sgs);
            } catch (error) {
                console.error("Failed to load data:", error);
            } finally {
                setLoading(false);
            }
        };

        loadData();
    }, []);

    const refreshTransactions = async () => {
        if (!db) return;
        const txs = await getTransactions(db);
        setTransactions(txs);
    };

    const refreshAccounts = async () => {
        if (!db) return;
        const accs = await getAccounts(db);
        setAccounts(accs);
    };

    const refreshBudgets = async () => {
        if (!db) return;
        const bgs = await getBudgets(db);
        setBudgets(bgs);
    };

    const refreshSavingsGoals = async () => {
        if (!db) return;
        const sgs = await getSavingsGoals(db);
        setSavingsGoals(sgs);
    };

    const refreshData = async () => {
        await Promise.all([
            refreshTransactions(),
            refreshAccounts(),
            refreshBudgets(),
            refreshSavingsGoals()
        ]);
    };

    return (
        <AppContext.Provider
            value={{
                db,
                transactions,
                accounts,
                budgets,
                savingsGoals,
                loading,
                refreshData,
                refreshTransactions,
                refreshAccounts,
                refreshBudgets,
                refreshSavingsGoals
            }}
        >
            {children}
        </AppContext.Provider>
    );
};

export const useApp = () => {
    const context = useContext(AppContext);
    if (!context) {
        throw new Error('useApp must be used within an AppProvider');
    }
    return context;
};
