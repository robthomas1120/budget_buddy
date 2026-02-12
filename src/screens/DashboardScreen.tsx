import React, { useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useTheme, Button } from 'react-native-paper';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import BalanceSummaryCard from '../components/BalanceSummaryCard';
import TransactionListItem from '../components/TransactionListItem';
import { deleteTransaction } from '../database/TransactionHelper';

const DashboardScreen = () => {
  const {
    transactions,
    accounts,
    budgets,
    loading,
    refreshData,
    db
  } = useApp();
  const theme = useTheme();
  const navigation = useNavigation<any>();

  const currentBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);

  // Sort transactions by date desc and take top 5
  const recentTransactions = [...transactions]
    .sort((a, b) => b.date - a.date)
    .slice(0, 5);

  const handleDeleteTransaction = async (id: number) => {
    if (db) {
      await deleteTransaction(db, id);
      await refreshData();
    }
  };

  const handleUpdateTransaction = (transaction: any) => {
    // Navigate to AddTransaction with params to edit
    navigation.navigate('AddTransaction', { transaction });
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={refreshData} />
        }
      >
        <BalanceSummaryCard
          currentBalance={currentBalance}
          onBalanceTap={() => navigation.navigate('Accounts')}
        />

        <View style={styles.sectionHeader}>
          <Text style={[styles.sectionTitle, { color: theme.colors.primary }]}>Recent Transactions</Text>
          <Button mode="text" onPress={() => { /* Navigate to All Transactions */ }}>
            See All
          </Button>
        </View>

        {recentTransactions.length === 0 ? (
          <View style={styles.emptyState}>
            <MaterialCommunityIcons name="file-document-outline" size={48} color="#ccc" />
            <Text style={styles.emptyText}>No transactions yet</Text>
            <Text style={styles.emptySubtext}>Add your first transaction by tapping the + button</Text>
          </View>
        ) : (
          recentTransactions.map(t => (
            <TransactionListItem
              key={t.id}
              transaction={t}
              onDelete={() => t.id && handleDeleteTransaction(t.id)}
              onUpdate={() => handleUpdateTransaction(t)}
            />
          ))
        )}
      </ScrollView>

      <View style={styles.fabContainer}>
        <Button
          mode="contained"
          style={styles.fab}
          contentStyle={styles.fabContent}
          onPress={() => navigation.navigate('AddTransaction')}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </Button>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 80, // Space for FAB
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 10,
    marginBottom: 5,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  emptyState: {
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 18,
    color: '#888',
    marginTop: 16,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#aaa',
    textAlign: 'center',
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

export default DashboardScreen;
