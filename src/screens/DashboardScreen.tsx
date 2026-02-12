import React, { useCallback } from 'react';
import { View, Text, ScrollView, RefreshControl, TouchableOpacity } from 'react-native';
import { useNavigation, NavigationProp } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
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
  const { theme } = useAppTheme();
  const themeClasses = getThemeClasses(theme);
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
    navigation.navigate('AddTransaction', { transaction });
  };

  const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

  return (
    <View className={`flex-1 ${themeClasses.bg.background}`}>
      <ScrollView
        className="p-4 pb-20"
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={refreshData} />
        }
      >
        <BalanceSummaryCard
          currentBalance={currentBalance}
          onBalanceTap={() => navigation.navigate('Accounts')}
        />

        <View className="flex-row justify-between items-center mt-2.5 mb-1.5">
          <Text className={`text-xl font-bold ${themeClasses.text.primary}`}>
            Recent Transactions
          </Text>
          <TouchableOpacity onPress={() => { /* Navigate to All Transactions */ }}>
            <Text className={themeClasses.text.secondary}>See All</Text>
          </TouchableOpacity>
        </View>

        {recentTransactions.length === 0 ? (
          <View className="items-center py-10">
            <MaterialCommunityIcons
              name="file-document-outline"
              size={48}
              color={theme === 'light' ? '#D1D5DB' : '#4B5563'}
            />
            <Text className={`text-lg ${themeClasses.text.secondary} mt-4`}>
              No transactions yet
            </Text>
            <Text className={`text-sm ${themeClasses.text.secondary} text-center mt-2`}>
              Add your first transaction by tapping the + button
            </Text>
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

      <View className="absolute bottom-5 right-5">
        <TouchableOpacity
          onPress={() => navigation.navigate('AddTransaction')}
          className="w-14 h-14 rounded-full items-center justify-center shadow-lg"
          style={{ backgroundColor: primaryColor }}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default DashboardScreen;
