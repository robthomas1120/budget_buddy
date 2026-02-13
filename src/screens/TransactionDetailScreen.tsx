import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';
import { Transaction } from '../types';

type RootStackParamList = {
    TransactionDetail: { transaction: Transaction };
    AddTransaction: { transaction: Transaction };
};

type TransactionDetailRouteProp = RouteProp<RootStackParamList, 'TransactionDetail'>;

const TransactionDetailScreen = () => {
    const navigation = useNavigation<any>();
    const route = useRoute<TransactionDetailRouteProp>();
    const { transaction } = route.params;
    const { accounts, budgets, deleteTransaction, db, refreshData } = useApp();
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const isTransfer = transaction.type === 'transfer';
    const isExpense = transaction.type === 'expense';
    const isIncome = transaction.type === 'income';

    // Find names
    const getSourceName = () => {
        if (transaction.accountId) {
            return accounts.find(a => a.id === transaction.accountId)?.name || 'Account';
        }
        if (transaction.budgetId) {
            return budgets.find(b => b.id === transaction.budgetId)?.title || 'Budget';
        }
        return 'Unknown';
    };

    const getDestinationName = () => {
        if (transaction.toAccountId) {
            return accounts.find(a => a.id === transaction.toAccountId)?.name || 'Account';
        }
        if (transaction.toBudgetId) {
            return budgets.find(b => b.id === transaction.toBudgetId)?.title || 'Budget';
        }
        return 'Unknown';
    };

    const handleEdit = () => {
        Alert.alert(
            'Edit Transaction',
            'Are you sure you want to edit this transaction?',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Edit',
                    onPress: () => navigation.navigate('AddTransaction', { transaction })
                }
            ]
        );
    };

    const handleDelete = () => {
        Alert.alert(
            'Delete Transaction',
            'Are you sure you want to delete this transaction? This action cannot be undone.',
            [
                { text: 'Cancel', style: 'cancel' },
                {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                        if (db && transaction.id) {
                            await deleteTransaction(db, transaction.id);
                            await refreshData();
                            navigation.goBack();
                        }
                    }
                }
            ]
        );
    };

    const InfoRow = ({ label, value, icon, color }: { label: string, value: string, icon: any, color?: string }) => (
        <View className="flex-row items-center justify-between py-4 border-b border-gray-100" style={{ borderBottomColor: theme === 'light' ? '#f3f4f6' : '#374151' }}>
            <View className="flex-row items-center">
                <View className={`w-8 h-8 rounded-full items-center justify-center mr-3 ${themeClasses.bg.surfaceVariant}`}>
                    <MaterialCommunityIcons name={icon} size={18} color={color || themeClasses.text.secondary.replace('text-', '')} />
                </View>
                <Text className={`text-sm ${themeClasses.text.secondary}`}>{label}</Text>
            </View>
            <Text className={`text-base font-medium ${themeClasses.text.primary}`}>{value}</Text>
        </View>
    );

    const amountColor = isIncome ? 'text-green-500' : isExpense ? 'text-red-500' : 'text-blue-500';

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            <ScrollView className="flex-1 p-4">
                {/* Header Section */}
                <View className="items-center py-8">
                    <Text className={`text-2xl font-bold ${themeClasses.text.primary} text-center mb-2`}>
                        {transaction.title}
                    </Text>
                    <Text className={`text-4xl font-bold ${amountColor}`}>
                        {isIncome ? '+' : isExpense ? '-' : ''}{currency.symbol}{transaction.amount.toFixed(2)}
                    </Text>
                    {isTransfer && transaction.fee ? (
                        <Text className={`text-sm ${themeClasses.text.secondary} mt-1`}>
                            Fee: {currency.symbol}{transaction.fee.toFixed(2)}
                        </Text>
                    ) : null}
                </View>

                {/* Details Card */}
                <View className={`p-4 rounded-2xl ${themeClasses.bg.surface} border ${themeClasses.border}`}>
                    <InfoRow
                        label="Type"
                        value={transaction.type.charAt(0).toUpperCase() + transaction.type.slice(1)}
                        icon={isTransfer ? 'swap-horizontal' : isIncome ? 'arrow-bottom-left' : 'arrow-top-right'}
                        color={isIncome ? '#10b981' : isExpense ? '#ef4444' : '#3b82f6'}
                    />
                    <InfoRow
                        label="Date"
                        value={new Date(transaction.date).toLocaleDateString(undefined, { dateStyle: 'long' })}
                        icon="calendar"
                    />

                    {!isTransfer ? (
                        <InfoRow
                            label="Source"
                            value={getSourceName()}
                            icon={transaction.accountId ? 'bank' : 'wallet'}
                        />
                    ) : (
                        <>
                            <InfoRow
                                label="From"
                                value={getSourceName()}
                                icon={transaction.accountId ? 'bank' : 'wallet'}
                            />
                            <InfoRow
                                label="To"
                                value={getDestinationName()}
                                icon={transaction.toAccountId ? 'bank' : 'wallet'}
                            />
                        </>
                    )}

                    <InfoRow
                        label="Category"
                        value={transaction.category || 'General'}
                        icon="tag-outline"
                    />

                    {transaction.notes ? (
                        <View className="py-4">
                            <View className="flex-row items-center mb-2">
                                <View className={`w-8 h-8 rounded-full items-center justify-center mr-3 ${themeClasses.bg.surfaceVariant}`}>
                                    <MaterialCommunityIcons name="note-text-outline" size={18} color={themeClasses.text.secondary.replace('text-', '')} />
                                </View>
                                <Text className={`text-sm ${themeClasses.text.secondary}`}>Notes</Text>
                            </View>
                            <Text className={`text-base ${themeClasses.text.primary} leading-6`}>
                                {transaction.notes}
                            </Text>
                        </View>
                    ) : null}
                </View>
            </ScrollView>

            {/* Bottom Actions */}
            <View className={`p-4 pb-10 flex-row space-x-4 border-t ${themeClasses.border} ${themeClasses.bg.surface}`}>
                <TouchableOpacity
                    className="flex-1 py-4 bg-red-500/10 rounded-xl items-center justify-center flex-row"
                    onPress={handleDelete}
                >
                    <MaterialCommunityIcons name="delete-outline" size={24} color="#ef4444" />
                    <Text className="text-red-500 font-bold ml-2">Delete</Text>
                </TouchableOpacity>

                <TouchableOpacity
                    className="flex-1 py-4 rounded-xl items-center justify-center flex-row"
                    style={{ backgroundColor: theme === 'dark-pink' ? '#ec4899' : '#10b981' }}
                    onPress={handleEdit}
                >
                    <MaterialCommunityIcons name="pencil-outline" size={24} color="white" />
                    <Text className="text-white font-bold ml-2">Edit Transaction</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default TransactionDetailScreen;
