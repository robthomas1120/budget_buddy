import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { insertTransaction, updateTransaction } from '../database/TransactionHelper';
import { updateAccount } from '../database/AccountHelper';
import { useCurrency } from '../context/CurrencyContext';

const AddTransactionScreen = () => {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const { accounts, budgets, refreshData, db } = useApp();
  const { theme } = useAppTheme();
  const { currency } = useCurrency();
  const themeClasses = getThemeClasses(theme);

  const editingTransaction = route.params?.transaction;
  const isEditing = !!editingTransaction;

  const [title, setTitle] = useState(editingTransaction?.title || '');
  const [amount, setAmount] = useState(editingTransaction?.amount?.toString() || '');
  const [type, setType] = useState<'expense' | 'income'>(editingTransaction?.type || 'expense');
  const category = editingTransaction?.category || 'General';
  const [accountId, setAccountId] = useState<number | undefined>(editingTransaction?.accountId || (accounts.length > 0 && !editingTransaction?.budgetId ? accounts[0].id : undefined));
  const [budgetId, setBudgetId] = useState<number | undefined>(editingTransaction?.budgetId);
  const [fundType, setFundType] = useState<'account' | 'budget'>(editingTransaction?.budgetId ? 'budget' : 'account');

  const categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Health', 'Education', 'Salary', 'Business', 'Gift', 'Other'];

  const handleSave = async () => {
    if (!title || !amount || !db) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    if (fundType === 'account' && !accountId) {
      Alert.alert('Error', 'Please select an account');
      return;
    }

    if (fundType === 'budget' && !budgetId) {
      Alert.alert('Error', 'Please select a budget');
      return;
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      Alert.alert('Error', 'Invalid amount');
      return;
    }

    try {
      const parsedAmount = parseFloat(amount);
      const balanceChange = type === 'income' ? parsedAmount : -parsedAmount;

      if (fundType === 'account') {
        const targetAccount = accounts.find(a => a.id === accountId);
        if (!targetAccount) {
          Alert.alert('Error', 'Account not found');
          return;
        }

        if (isEditing) {
          // Find old account to revert (if it was an account transaction)
          const oldAccountId = editingTransaction.accountId;
          if (oldAccountId) {
            const oldAccount = accounts.find(a => a.id === oldAccountId);
            if (oldAccount) {
              const revertAmount = editingTransaction.type === 'income' ? -editingTransaction.amount : editingTransaction.amount;
              await updateAccount(db, { ...oldAccount, balance: oldAccount.balance + revertAmount });
            }
          }

          // Update transaction
          await updateTransaction(db, {
            ...editingTransaction,
            title,
            amount: parsedAmount,
            type,
            category,
            accountId,
            budgetId: null // Explicitly clear budget
          });

          // Re-fetch target account to get reverted balance if it was the same account
          const refreshedTargetAccount = (await db.getFirstAsync<any>('SELECT * FROM accounts WHERE id = ?', [accountId]));
          if (refreshedTargetAccount.balance + balanceChange < 0) {
            // Rollback or just alert (this is complex in manual mode, but user only wanted validation)
            Alert.alert('Insufficient Funds', `This transaction would result in a negative balance.`);
            // Need to refresh to show revert
            await refreshData();
            return;
          }
          await updateAccount(db, { ...refreshedTargetAccount, balance: refreshedTargetAccount.balance + balanceChange });
        } else {
          if (targetAccount.balance + balanceChange < 0) {
            Alert.alert('Insufficient Funds', `You don't have enough balance in ${targetAccount.name}.`);
            return;
          }
          await insertTransaction(db, {
            title, amount: parsedAmount, type, category, date: Date.now(), accountId, budgetId: null, notes: ''
          });
          await updateAccount(db, { ...targetAccount, balance: targetAccount.balance + balanceChange });
        }
      } else {
        // Budget-based transaction
        const targetBudget = budgets.find(b => b.id === budgetId);
        if (!targetBudget) {
          Alert.alert('Error', 'Budget not found');
          return;
        }

        // Repurposed 'spent' is balance. For budgets: income increases balance, expense decreases.
        if (targetBudget.spent + balanceChange < 0) {
          Alert.alert('Insufficient Funds', `Not enough funds in Budget: ${targetBudget.title}`);
          return;
        }

        if (isEditing) {
          // If it was an account transaction before, revert the account
          if (editingTransaction.accountId) {
            const oldAccount = accounts.find(a => a.id === editingTransaction.accountId);
            if (oldAccount) {
              const revertAmount = editingTransaction.type === 'income' ? -editingTransaction.amount : editingTransaction.amount;
              await updateAccount(db, { ...oldAccount, balance: oldAccount.balance + revertAmount });
            }
          }

          await updateTransaction(db, {
            ...editingTransaction,
            title,
            amount: parsedAmount,
            type,
            category,
            accountId: null, // Explicitly clear account
            budgetId
          });
        } else {
          await insertTransaction(db, {
            title, amount: parsedAmount, type, category, date: Date.now(), accountId: null, budgetId, notes: ''
          });
        }
      }

      await refreshData();
      navigation.goBack();
    } catch (error) {
      console.error(error);
      Alert.alert('Error', 'Failed to save transaction');
    }
  };

  const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

  // Theme-aware Toggle Styles
  const toggleContainerBg = theme === 'light' ? 'bg-gray-200' : theme === 'dark' ? 'bg-gray-800' : 'bg-zinc-900';
  const activeItemBg = theme === 'light' ? 'bg-white shadow-sm' : theme === 'dark' ? 'bg-gray-700 shadow-sm' : 'bg-zinc-800 shadow-sm';
  const activeTextColor = theme === 'light' ? 'text-gray-900' : 'text-white';

  return (
    <View className={`flex-1 ${themeClasses.bg.background}`}>
      <ScrollView className="p-4">
        {/* Type Selector */}
        <View className={`flex-row mb-4 rounded-lg p-1 border ${themeClasses.border} ${toggleContainerBg}`}>
          <TouchableOpacity
            className={`flex-1 py-2 rounded-md ${type === 'expense' ? activeItemBg : ''}`}
            onPress={() => setType('expense')}
          >
            <Text className={`text-center font-semibold ${type === 'expense' ? 'text-red-500' : 'text-gray-500'}`}>Expense</Text>
          </TouchableOpacity>
          <TouchableOpacity
            className={`flex-1 py-2 rounded-md ${type === 'income' ? activeItemBg : ''}`}
            onPress={() => setType('income')}
          >
            <Text className={`text-center font-semibold ${type === 'income' ? 'text-green-500' : 'text-gray-500'}`}>Income</Text>
          </TouchableOpacity>
        </View>

        {/* Amount Input */}
        <View className="mb-4">
          <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Amount</Text>
          <View className={`flex-row items-center border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface}`}>
            <Text className={`text-lg font-bold mr-2 ${themeClasses.text.primary}`}>{currency.symbol}</Text>
            <TextInput
              value={amount}
              onChangeText={setAmount}
              keyboardType="numeric"
              placeholder="0.00"
              placeholderTextColor="#9CA3AF"
              className={`flex-1 text-xl font-bold ${themeClasses.text.primary}`}
            />
          </View>
        </View>

        {/* Title Input */}
        <View className="mb-4">
          <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Title</Text>
          <TextInput
            value={title}
            onChangeText={setTitle}
            placeholder="What is this for?"
            placeholderTextColor="#9CA3AF"
            className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
          />
        </View>

        {/* Fund Type Picker (Transaction Source) */}
        <View className="mb-4">
          <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Transaction Source</Text>
          <View className={`flex-row rounded-lg p-1 border ${themeClasses.border} ${toggleContainerBg}`}>
            <TouchableOpacity
              className={`flex-1 py-2 rounded-md ${fundType === 'account' ? activeItemBg : ''}`}
              onPress={() => setFundType('account')}
            >
              <View className="flex-row items-center justify-center">
                <MaterialCommunityIcons name="bank" size={16} color={fundType === 'account' ? primaryColor : '#9CA3AF'} className="mr-2" />
                <Text className={`font-semibold ${fundType === 'account' ? activeTextColor : themeClasses.text.secondary}`}>Accounts</Text>
              </View>
            </TouchableOpacity>
            <TouchableOpacity
              className={`flex-1 py-2 rounded-md ${fundType === 'budget' ? activeItemBg : ''}`}
              onPress={() => setFundType('budget')}
            >
              <View className="flex-row items-center justify-center">
                <MaterialCommunityIcons name="wallet" size={16} color={fundType === 'budget' ? primaryColor : '#9CA3AF'} className="mr-2" />
                <Text className={`font-semibold ${fundType === 'budget' ? activeTextColor : themeClasses.text.secondary}`}>Budgets</Text>
              </View>
            </TouchableOpacity>
          </View>
        </View>

        {/* Conditional Account/Budget Selector */}
        {fundType === 'account' ? (
          <View className="mb-6">
            <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Accounts</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
              {accounts.map(acc => (
                <TouchableOpacity
                  key={acc.id}
                  onPress={() => setAccountId(acc.id)}
                  className={`mr-2 px-4 py-3 rounded-xl border ${accountId === acc.id ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                  style={accountId === acc.id ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                >
                  <Text className={`font-semibold ${themeClasses.text.primary}`}>{acc.name}</Text>
                  <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>{currency.symbol}{acc.balance.toFixed(2)}</Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        ) : (
          <View className="mb-6">
            <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Budgets</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
              {budgets.filter(b => b.isActive).map(budget => (
                <TouchableOpacity
                  key={budget.id}
                  onPress={() => setBudgetId(budget.id)}
                  className={`mr-2 px-4 py-3 rounded-xl border ${budgetId === budget.id ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                  style={budgetId === budget.id ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                >
                  <View className="flex-row items-center justify-between">
                    <Text className={`font-semibold ${themeClasses.text.primary} mr-2`}>{budget.title}</Text>
                  </View>
                  <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>
                    Balance: {currency.symbol}{budget.spent.toFixed(2)}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        )}

      </ScrollView>

      <View className={`p-4 pb-10 border-t ${themeClasses.border} ${themeClasses.bg.surface}`}>
        <TouchableOpacity
          onPress={handleSave}
          className="py-4 rounded-xl items-center shadow-sm"
          style={{ backgroundColor: primaryColor }}
        >
          <Text className="text-white font-bold text-lg">
            {isEditing ? 'Update Transaction' : 'Save Transaction'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default AddTransactionScreen;
