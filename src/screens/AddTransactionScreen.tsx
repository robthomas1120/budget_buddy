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
import { Transaction } from '../types';

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
  const [type, setType] = useState<'expense' | 'income' | 'transfer'>(editingTransaction?.type || 'expense');
  const category = editingTransaction?.category || 'General';
  const [accountId, setAccountId] = useState<number | undefined>(editingTransaction?.accountId || (accounts.length > 0 && !editingTransaction?.budgetId ? accounts[0].id : undefined));
  const [budgetId, setBudgetId] = useState<number | undefined>(editingTransaction?.budgetId);
  const [fundType, setFundType] = useState<'account' | 'budget'>(editingTransaction?.budgetId ? 'budget' : 'account');

  // Transfer specific states
  const [toAccountId, setToAccountId] = useState<number | undefined>(editingTransaction?.toAccountId || (accounts.length > 1 && !editingTransaction?.toBudgetId ? accounts[1].id : undefined));
  const [toBudgetId, setToBudgetId] = useState<number | undefined>(editingTransaction?.toBudgetId);
  const [toFundType, setToFundType] = useState<'account' | 'budget'>(editingTransaction?.toBudgetId ? 'budget' : 'account');
  const [fee, setFee] = useState(editingTransaction?.fee?.toString() || '0');

  const categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Health', 'Education', 'Salary', 'Business', 'Gift', 'Other'];

  const handleSave = async () => {
    const isTitleRequired = type !== 'transfer';
    if ((isTitleRequired && !title) || !amount || !db) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    const parsedAmount = parseFloat(amount);
    const parsedFee = parseFloat(fee) || 0;
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      Alert.alert('Error', 'Invalid amount');
      return;
    }
    if (isNaN(parsedFee) || parsedFee < 0) {
      Alert.alert('Error', 'Invalid fee');
      return;
    }

    // Validation for Income/Expense
    if (type !== 'transfer') {
      if (fundType === 'account' && !accountId) {
        Alert.alert('Error', 'Please select an account');
        return;
      }
      if (fundType === 'budget' && !budgetId) {
        Alert.alert('Error', 'Please select a budget');
        return;
      }
    } else {
      // Validation for Transfer
      if (fundType === 'account' && !accountId) {
        Alert.alert('Error', 'Please select a source account');
        return;
      }
      if (fundType === 'budget' && !budgetId) {
        Alert.alert('Error', 'Please select a source budget');
        return;
      }
      if (toFundType === 'account' && !toAccountId) {
        Alert.alert('Error', 'Please select a destination account');
        return;
      }
      if (toFundType === 'budget' && !toBudgetId) {
        Alert.alert('Error', 'Please select a destination budget');
        return;
      }

      // Prevent same source and destination
      if (fundType === toFundType) {
        if (fundType === 'account' && accountId === toAccountId) {
          Alert.alert('Error', 'Source and destination account cannot be the same');
          return;
        }
        if (fundType === 'budget' && budgetId === toBudgetId) {
          Alert.alert('Error', 'Source and destination budget cannot be the same');
          return;
        }
      }
    }

    try {
      // 1. Revert Old Balances (Common logic for editing)
      if (isEditing) {
        // Revert Source (Account only)
        if (editingTransaction.accountId) {
          const oldAccount = accounts.find(a => a.id === editingTransaction.accountId);
          if (oldAccount) {
            const revertAmount = editingTransaction.type === 'income' ? -editingTransaction.amount : (editingTransaction.amount + (editingTransaction.fee || 0));
            await updateAccount(db, { ...oldAccount, balance: oldAccount.balance + revertAmount });
          }
        }
        // Revert Destination (Account only, for transfers)
        if (editingTransaction.type === 'transfer' && editingTransaction.toAccountId) {
          const oldToAccount = accounts.find(a => a.id === editingTransaction.toAccountId);
          if (oldToAccount) {
            await updateAccount(db, { ...oldToAccount, balance: oldToAccount.balance - editingTransaction.amount });
          }
        }
        // Budgets are dynamic, no manual revert needed for them
      }

      // Re-fetch current balances after potential reverts
      const updatedAccounts = await db.getAllAsync<any>('SELECT * FROM accounts');

      // 2. Perform Balance Checks and Updates
      if (type === 'transfer') {
        const totalDeduction = parsedAmount + parsedFee;

        // Source Check
        if (fundType === 'account') {
          const sourceAcc = updatedAccounts.find(a => a.id === accountId);
          if (sourceAcc.balance < totalDeduction) {
            Alert.alert('Insufficient Funds', `Source account ${sourceAcc.name} has insufficient funds.`);
            await refreshData(); // Recover UI state
            return;
          }
          await updateAccount(db, { ...sourceAcc, balance: sourceAcc.balance - totalDeduction });
        } else {
          // Budget source check
          const sourceBudget = budgets.find(b => b.id === budgetId);
          if (sourceBudget.spent < totalDeduction) {
            Alert.alert('Insufficient Funds', `Source budget ${sourceBudget.title} has insufficient funds.`);
            await refreshData();
            return;
          }
        }

        // Destination Update (Account only)
        if (toFundType === 'account') {
          const targetAcc = updatedAccounts.find(a => a.id === toAccountId);
          // Re-fetch as it might be the same as source account (unlikely due to validation but safe)
          const targetAccRefreshed = await db.getFirstAsync<any>('SELECT * FROM accounts WHERE id = ?', [toAccountId]);
          await updateAccount(db, { ...targetAccRefreshed, balance: targetAccRefreshed.balance + parsedAmount });
        }

        // Generate automated title for transfers
        let sourceName = fundType === 'account' ?
          accounts.find(a => a.id === accountId)?.name :
          budgets.find(b => b.id === budgetId)?.title;
        let targetName = toFundType === 'account' ?
          accounts.find(a => a.id === toAccountId)?.name :
          budgets.find(b => b.id === toBudgetId)?.title;

        const generatedTitle = `From ${sourceName} to ${targetName}${parsedFee > 0 ? ` (Fee: ${currency.symbol}${parsedFee})` : ''}`;

        // Save Transfer Transaction
        const transData: Transaction = {
          title: generatedTitle, amount: parsedAmount, type: 'transfer', category, date: isEditing ? editingTransaction.date : Date.now(),
          accountId: fundType === 'account' ? accountId : undefined,
          budgetId: fundType === 'budget' ? budgetId : undefined,
          toAccountId: toFundType === 'account' ? toAccountId : undefined,
          toBudgetId: toFundType === 'budget' ? toBudgetId : undefined,
          fee: parsedFee,
          notes: ''
        };

        if (isEditing) {
          await updateTransaction(db, { ...transData, id: editingTransaction.id });
        } else {
          await insertTransaction(db, transData);
        }
      } else {
        // Handle Income/Expense (Refactored logic)
        const balanceChange = type === 'income' ? parsedAmount : -parsedAmount;

        if (fundType === 'account') {
          const targetAccount = updatedAccounts.find(a => a.id === accountId);
          if (targetAccount.balance + balanceChange < 0) {
            Alert.alert('Insufficient Funds', 'Insufficient balance in account.');
            await refreshData();
            return;
          }
          await updateAccount(db, { ...targetAccount, balance: targetAccount.balance + balanceChange });
        } else {
          const targetBudget = budgets.find(b => b.id === budgetId);
          if (targetBudget.spent + balanceChange < 0) {
            Alert.alert('Insufficient Funds', 'Insufficient funds in budget.');
            await refreshData();
            return;
          }
        }

        const transData: Transaction = {
          title, amount: parsedAmount, type: type as 'expense' | 'income', category, date: isEditing ? editingTransaction.date : Date.now(),
          accountId: fundType === 'account' ? accountId : undefined,
          budgetId: fundType === 'budget' ? budgetId : undefined,
          notes: ''
        };

        if (isEditing) {
          await updateTransaction(db, { ...transData, id: editingTransaction.id });
        } else {
          await insertTransaction(db, transData);
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
          <TouchableOpacity
            className={`flex-1 py-2 rounded-md ${type === 'transfer' ? activeItemBg : ''}`}
            onPress={() => setType('transfer')}
          >
            <Text className={`text-center font-semibold ${type === 'transfer' ? activeTextColor : 'text-gray-500'}`}>Transfer</Text>
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

        {/* Title Input (Hidden for Transfers) */}
        {type !== 'transfer' && (
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
        )}

        {/* Fund Type Picker (Transaction Source) */}
        <View className="mb-4">
          <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>{type === 'transfer' ? 'From' : 'Transaction Source'}</Text>
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

        {/* Transfer Destination and Fee */}
        {type === 'transfer' && (
          <View>
            {/* Destination Picker */}
            <View className="mb-4">
              <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>To</Text>
              <View className={`flex-row rounded-lg p-1 border ${themeClasses.border} ${toggleContainerBg}`}>
                <TouchableOpacity
                  className={`flex-1 py-2 rounded-md ${toFundType === 'account' ? activeItemBg : ''}`}
                  onPress={() => setToFundType('account')}
                >
                  <View className="flex-row items-center justify-center">
                    <MaterialCommunityIcons name="bank" size={16} color={toFundType === 'account' ? primaryColor : '#9CA3AF'} className="mr-2" />
                    <Text className={`font-semibold ${toFundType === 'account' ? activeTextColor : themeClasses.text.secondary}`}>Accounts</Text>
                  </View>
                </TouchableOpacity>
                <TouchableOpacity
                  className={`flex-1 py-2 rounded-md ${toFundType === 'budget' ? activeItemBg : ''}`}
                  onPress={() => setToFundType('budget')}
                >
                  <View className="flex-row items-center justify-center">
                    <MaterialCommunityIcons name="wallet" size={16} color={toFundType === 'budget' ? primaryColor : '#9CA3AF'} className="mr-2" />
                    <Text className={`font-semibold ${toFundType === 'budget' ? activeTextColor : themeClasses.text.secondary}`}>Budgets</Text>
                  </View>
                </TouchableOpacity>
              </View>
            </View>

            {/* Conditional Destination Account/Budget Selector */}
            {toFundType === 'account' ? (
              <View className="mb-6">
                <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Target Account</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
                  {accounts.map(acc => (
                    <TouchableOpacity
                      key={acc.id}
                      onPress={() => setToAccountId(acc.id)}
                      className={`mr-2 px-4 py-3 rounded-xl border ${toAccountId === acc.id ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                      style={toAccountId === acc.id ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                    >
                      <Text className={`font-semibold ${themeClasses.text.primary}`}>{acc.name}</Text>
                      <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>{currency.symbol}{acc.balance.toFixed(2)}</Text>
                    </TouchableOpacity>
                  ))}
                </ScrollView>
              </View>
            ) : (
              <View className="mb-6">
                <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Target Budget</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
                  {budgets.filter(b => b.isActive).map(budget => (
                    <TouchableOpacity
                      key={budget.id}
                      onPress={() => setToBudgetId(budget.id)}
                      className={`mr-2 px-4 py-3 rounded-xl border ${toBudgetId === budget.id ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                      style={toBudgetId === budget.id ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
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

            {/* Fee Input */}
            <View className="mb-4">
              <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Transaction Fee (Optional)</Text>
              <View className={`flex-row items-center border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface}`}>
                <Text className={`text-lg font-bold mr-2 ${themeClasses.text.primary}`}>{currency.symbol}</Text>
                <TextInput
                  value={fee}
                  onChangeText={setFee}
                  keyboardType="numeric"
                  placeholder="0.00"
                  placeholderTextColor="#9CA3AF"
                  className={`flex-1 text-xl font-bold ${themeClasses.text.primary}`}
                />
              </View>
            </View>
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
