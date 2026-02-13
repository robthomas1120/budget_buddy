import React, { useMemo } from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';
import TransactionListItem from '../components/TransactionListItem';
import { deleteBudget } from '../database/BudgetHelper';

const BudgetDetailsScreen = () => {
    const route = useRoute<any>();
    const navigation = useNavigation<any>();
    const { budgetId } = route.params;
    const { budgets, transactions, db, refreshData } = useApp();
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const budget = budgets.find(b => b.id === budgetId);

    const budgetTransactions = useMemo(() => {
        return transactions
            .filter(t => t.budgetId === budgetId || t.toBudgetId === budgetId)
            .sort((a, b) => b.date - a.date);
    }, [transactions, budgetId]);

    const handleDelete = async () => {
        Alert.alert(
            'Delete Budget',
            'Are you sure you want to delete this budget? Linked transactions will stay but won\'t be associated with a budget anymore.',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        if (db) {
                            await deleteBudget(db, budgetId);
                            await refreshData();
                            navigation.goBack();
                        }
                    }
                }
            ]
        );
    };

    if (!budget) {
        return (
            <View className={`flex-1 items-center justify-center ${themeClasses.bg.background}`}>
                <Text className={themeClasses.text.primary}>Budget not found</Text>
            </View>
        );
    }

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            {/* Header / Info Section */}
            <View className={`p-6 ${themeClasses.bg.surface} border-b ${themeClasses.border} items-center`}>
                <Text className={`text-sm ${themeClasses.text.secondary} uppercase font-bold tracking-wider mb-1`}>
                    Total Balance
                </Text>
                <Text className={`text-3xl font-bold ${budget.spent >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {currency.symbol}{budget.spent.toFixed(2)}
                </Text>
            </View>

            {/* Transaction List */}
            <ScrollView className="flex-1 p-4">
                <Text className={`text-sm font-semibold mb-3 ${themeClasses.text.secondary}`}>
                    Transaction History
                </Text>

                {budgetTransactions.length === 0 ? (
                    <View className="items-center py-10">
                        <MaterialCommunityIcons name="text-box-remove-outline" size={48} color={theme === 'light' ? '#D1D5DB' : '#4B5563'} />
                        <Text className={`text-sm ${themeClasses.text.secondary} mt-2`}>No transactions linked to this budget</Text>
                    </View>
                ) : (
                    budgetTransactions.map(t => (
                        <TransactionListItem
                            key={t.id}
                            transaction={t}
                            isOutflow={t.type === 'transfer' ? t.budgetId === budgetId : t.type === 'expense'}
                            onUpdate={() => navigation.navigate('TransactionDetail', { transaction: t })}
                            onDelete={() => { }} // Handle deletion if needed, but AppContext handles global state
                        />
                    ))
                )}

                {/* Space at the bottom */}
                <View className="h-20" />
            </ScrollView>

            {/* Actions Bar */}
            <View className={`p-4 pb-10 flex-row bg-transparent absolute bottom-0 left-0 right-0`}>
                <TouchableOpacity
                    onPress={handleDelete}
                    className="flex-1 py-4 rounded-xl items-center bg-red-500 shadow-sm"
                >
                    <Text className="text-white font-bold">Delete Budget</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default BudgetDetailsScreen;
