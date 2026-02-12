import React from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useTheme, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import AccountListItem from '../components/AccountListItem';

const AccountsScreen = () => {
  const { accounts, loading, refreshData } = useApp();
  const theme = useTheme();
  const navigation = useNavigation<any>();

  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={refreshData} />
        }
      >
        <View style={[styles.summaryCard, { backgroundColor: theme.colors.primary }]}>
          <Text style={styles.summaryLabel}>Total Balance</Text>
          <Text style={styles.summaryAmount}>₱{totalBalance.toFixed(2)}</Text>
        </View>

        <Text style={[styles.sectionTitle, { color: theme.colors.primary }]}>Your Accounts</Text>

        {accounts.length === 0 ? (
          <View style={styles.emptyState}>
            <MaterialCommunityIcons name="bank-outline" size={64} color="#ccc" />
            <Text style={styles.emptyText}>No accounts yet</Text>
            <Button
              mode="text"
              onPress={() => navigation.navigate('AddAccount')}
            >
              Add Account
            </Button>
          </View>
        ) : (
          accounts.map(account => (
            <AccountListItem
              key={account.id}
              account={account}
              onPress={() => { /* Edit or details */ }}
            />
          ))
        )}
      </ScrollView>

      <View style={styles.fabContainer}>
        <Button
          mode="contained"
          style={styles.fab}
          contentStyle={styles.fabContent}
          onPress={() => navigation.navigate('AddAccount')}
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
    marginBottom: 16,
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

export default AccountsScreen;
