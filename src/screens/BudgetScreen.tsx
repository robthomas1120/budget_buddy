import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useTheme, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import BudgetListItem from '../components/BudgetListItem';

const BudgetScreen = () => {
  const { budgets, scores, loading, refreshData, db } = useApp() as any; // forceful type cast for now as AppContext might be outdated in my thought model
  const theme = useTheme();
  const navigation = useNavigation<any>();

  // Filter for active budgets logic could go here, for now showing all
  const activeBudgets = budgets;

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={refreshData} />
        }
      >
        {activeBudgets.length === 0 ? (
          <View style={styles.emptyState}>
            <MaterialCommunityIcons name="currency-usd" size={64} color="#ccc" />
            <Text style={styles.emptyText}>No budgets yet</Text>
            <Text style={styles.emptySubtext}>Create a budget to track your spending</Text>
            <Button
              mode="contained"
              style={styles.emptyButton}
              onPress={() => navigation.navigate('AddBudget')}
            >
              Add Budget
            </Button>
          </View>
        ) : (
          activeBudgets.map((budget: any) => (
            <BudgetListItem
              key={budget.id}
              budget={budget}
              onPress={() => { /* Show details */ }}
            />
          ))
        )}
      </ScrollView>

      {activeBudgets.length > 0 && (
        <View style={styles.fabContainer}>
          <Button
            mode="contained"
            style={styles.fab}
            contentStyle={styles.fabContent}
            onPress={() => { /* Navigate to Add Budget */ }}
          >
            <MaterialCommunityIcons name="plus" size={30} color="white" />
          </Button>
        </View>
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
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 100,
  },
  emptyText: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 16,
    color: '#444',
  },
  emptySubtext: {
    fontSize: 16,
    color: '#888',
    marginTop: 8,
    marginBottom: 24,
  },
  emptyButton: {
    paddingHorizontal: 16,
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

export default BudgetScreen;
