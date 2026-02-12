export interface Transaction {
  id?: number;
  title: string;
  amount: number;
  type: 'income' | 'expense';
  category: string;
  date: number; // stored as milliseconds since epoch
  notes?: string;
  accountId?: number;
  budgetId?: number;
}

export interface Account {
  id?: number;
  name: string;
  type: string;
  iconName?: string;
  color?: string;
  balance: number;
}

export interface Budget {
  id?: number;
  title: string;
  category: string;
  amount: number;
  period: 'weekly' | 'monthly';
  startDate: number;
  endDate: number;
  spent: number;
  accountIds?: number[]; // Stored as comma-separated string in DB
  isActive: boolean;
}

export interface SavingsGoal {
  id?: number;
  name: string;
  reason?: string;
  targetAmount: number;
  currentAmount: number;
  startDate: number;
  targetDate: number;
  accountId?: number;
  isActive: boolean; // Stored as 0/1 in DB
  icon?: string;
  color?: string;
}
