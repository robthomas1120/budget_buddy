import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import SavingsGoalListItem from '../components/SavingsGoalListItem';
import DepositModal from '../components/DepositModal';
import { updateAccount } from '../database/AccountHelper';
import { updateSavingsGoal } from '../database/SavingsHelper';
import { insertTransaction } from '../database/TransactionHelper';
import { useCurrency } from '../context/CurrencyContext';

const SavingsScreen = () => {
  const { savingsGoals, accounts, refreshData, db } = useApp();
  const { theme } = useAppTheme();
  const { currency } = useCurrency();
  const themeClasses = getThemeClasses(theme);
  const navigation = useNavigation<any>();

  const [depositModalVisible, setDepositModalVisible] = useState(false);
  const [selectedGoal, setSelectedGoal] = useState<any>(null);

  const totalSaved = savingsGoals.reduce((sum, goal) => sum + goal.currentAmount, 0);
  const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

  const handleDeposit = async (amount: number, accountId: number) => {
    if (!db || !selectedGoal) return;

    try {
      const account = accounts.find(a => a.id === accountId);
      if (!account) {
        alert('Account not found');
        return;
      }

      if (account.balance < amount) {
        Alert.alert('Insufficient Balance', `You don't have enough funds in ${account.name} for this deposit.`);
        return;
      }

      // Deduct from account
      await updateAccount(db, { ...account, balance: account.balance - amount });

      // Add to savings goal
      await updateSavingsGoal(db, {
        ...selectedGoal,
        currentAmount: selectedGoal.currentAmount + amount,
      });

      // Create transaction record
      await insertTransaction(db, {
        title: `Deposit to ${selectedGoal.name}`,
        amount,
        type: 'expense',
        category: 'Savings',
        date: Date.now(),
        notes: `Deposited to savings goal`,
        accountId,
      });

      await refreshData();
      setDepositModalVisible(false);
      setSelectedGoal(null);
    } catch (error) {
      console.error('Deposit failed:', error);
      alert('Deposit failed');
    }
  };

  const openDepositModal = (goal: any) => {
    setSelectedGoal(goal);
    setDepositModalVisible(true);
  };

  return (
    <View className={`flex-1 ${themeClasses.bg.background}`}>
      <ScrollView className="p-4 pb-20">
        <View className={`p-5 rounded-xl mb-4 items-center`} style={{ backgroundColor: primaryColor }}>
          <Text className="text-white/90 text-base mb-1">Total Saved</Text>
          <Text className="text-white text-3xl font-bold">{currency.symbol}{totalSaved.toFixed(2)}</Text>
        </View>

        <Text className={`text-xl font-bold mb-3 ${themeClasses.text.primary}`}>
          Your Goals
        </Text>

        {savingsGoals.length === 0 ? (
          <View className="items-center py-20">
            <MaterialCommunityIcons
              name="piggy-bank-outline"
              size={64}
              color={theme === 'light' ? '#D1D5DB' : '#4B5563'}
            />
            <Text className={`text-lg ${themeClasses.text.secondary} mt-4`}>
              No savings goals yet
            </Text>
            <Text className={`text-sm ${themeClasses.text.secondary} text-center mt-2 px-6`}>
              Create a goal to start saving
            </Text>
          </View>
        ) : (
          savingsGoals.map(goal => (
            <SavingsGoalListItem
              key={goal.id}
              goal={goal}
              onPress={() => {
                // Navigate to goal details if needed
              }}
              onDeposit={() => openDepositModal(goal)}
            />
          ))
        )}
      </ScrollView>

      <View className="absolute bottom-5 right-5">
        <TouchableOpacity
          onPress={() => navigation.navigate('AddSavingsGoal')}
          className="w-14 h-14 rounded-full items-center justify-center shadow-lg"
          style={{ backgroundColor: primaryColor }}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </TouchableOpacity>
      </View>

      {selectedGoal && (
        <DepositModal
          visible={depositModalVisible}
          onClose={() => {
            setDepositModalVisible(false);
            setSelectedGoal(null);
          }}
          onDeposit={handleDeposit}
          accounts={accounts}
          goalName={selectedGoal.name}
        />
      )}
    </View>
  );
};

export default SavingsScreen;
