import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, Alert } from 'react-native';
import { useTheme, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import SavingsGoalListItem from '../components/SavingsGoalListItem';
import DepositModal from '../components/DepositModal';
import { updateSavingsGoal } from '../database/SavingsHelper';
import { updateAccount } from '../database/AccountHelper';
import { insertTransaction } from '../database/TransactionHelper';
import { SavingsGoal, Account, Transaction } from '../types';

const SavingsScreen = () => {
  const { savingsGoals, accounts, loading, refreshData, db } = useApp();
  const theme = useTheme();
  const navigation = useNavigation<any>();

  const [depositModalVisible, setDepositModalVisible] = useState(false);
  const [selectedGoal, setSelectedGoal] = useState<SavingsGoal | null>(null);

  const totalSaved = savingsGoals.reduce((sum, goal) => sum + goal.currentAmount, 0);

  const openDepositModal = (goal: SavingsGoal) => {
    setSelectedGoal(goal);
    setDepositModalVisible(true);
  };

  const handleDeposit = async (amount: number, accountId: number) => {
    if (!db || !selectedGoal) return;

    const account = accounts.find(a => a.id === accountId);
    if (!account) {
      Alert.alert('Error', 'Account not found');
      return;
    }

    if (account.balance < amount) {
      Alert.alert('Error', 'Insufficient funds in selected account');
      return;
    }

    try {
      // 1. Deduct from Account
      const updatedAccount: Account = { ...account, balance: account.balance - amount };
      await updateAccount(db, updatedAccount);

      // 2. Add to Savings Goal
      const updatedGoal: SavingsGoal = { ...selectedGoal, currentAmount: selectedGoal.currentAmount + amount };
      await updateSavingsGoal(db, updatedGoal);

      // 3. Create Transaction Record
      const transaction: Transaction = {
        title: `Deposit to ${selectedGoal.name}`,
        amount: amount,
        type: 'expense', // Considered expense from account view, or transfer
        category: 'Savings',
        date: Date.now(),
        accountId: accountId,
        notes: 'Auto-generated deposit'
      };
      await insertTransaction(db, transaction);

      await refreshData();
      Alert.alert('Success', 'Deposit successful!');

    } catch (error) {
      console.error(error);
      Alert.alert('Error', 'Failed to process deposit');
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={refreshData} />
        }
      >
        <View style={[styles.summaryCard, { backgroundColor: theme.colors.primary }]}>
          <Text style={styles.summaryLabel}>Total Saved</Text>
          <Text style={styles.summaryAmount}>₱{totalSaved.toFixed(2)}</Text>
        </View>

        <Text style={[styles.sectionTitle, { color: theme.colors.primary }]}>Your Goals</Text>

        {savingsGoals.length === 0 ? (
          <View style={styles.emptyState}>
            <MaterialCommunityIcons name="piggy-bank-outline" size={64} color="#ccc" />
            <Text style={styles.emptyText}>No savings goals yet</Text>
            <Text style={styles.emptySubtext}>Start saving for something special</Text>
            <Button
              mode="text"
              style={styles.emptyButton}
              onPress={() => navigation.navigate('AddSavingsGoal')}
            >
              Create Goal
            </Button>
          </View>
        ) : (
          savingsGoals.map(goal => (
            <SavingsGoalListItem
              key={goal.id}
              goal={goal}
              onPress={() => { /* Detail view */ }}
              onDeposit={() => openDepositModal(goal)}
            />
          ))
        )}
      </ScrollView>

      <View style={styles.fabContainer}>
        <Button
          mode="contained"
          style={styles.fab}
          contentStyle={styles.fabContent}
          onPress={() => navigation.navigate('AddSavingsGoal')}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </Button>
      </View>

      {selectedGoal && (
        <DepositModal
          visible={depositModalVisible}
          onClose={() => setDepositModalVisible(false)}
          onDeposit={handleDeposit}
          accounts={accounts}
          goalName={selectedGoal.name}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 80,
  },
  summaryCard: {
    padding: 24,
    borderRadius: 12,
    marginBottom: 24,
    alignItems: 'center',
    elevation: 4,
  },
  summaryLabel: {
    color: 'white',
    fontSize: 16,
    marginBottom: 8,
    opacity: 0.9,
  },
  summaryAmount: {
    color: 'white',
    fontSize: 32,
    fontWeight: 'bold',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  emptyState: {
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#888',
    marginTop: 16,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#aaa',
    marginBottom: 24,
  },
  emptyButton: {
    marginTop: 8,
  },
  fabContainer: {
    position: 'absolute',
    bottom: 20,
    right: 20,
  },
  fab: {
    borderRadius: 30,
    minWidth: 56,
    height: 56,
    justifyContent: 'center',
    alignItems: 'center',
  },
  fabContent: {
    height: 56,
  }
});

export default SavingsScreen;
