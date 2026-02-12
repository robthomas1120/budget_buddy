import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Transaction } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';

interface TransactionListItemProps {
    transaction: Transaction;
    onDelete: () => void;
    onUpdate: () => void;
}

const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, onDelete, onUpdate }) => {
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const isExpense = transaction.type === 'expense';
    const amountColor = isExpense ? 'text-red-500' : 'text-green-500';
    const iconName = isExpense ? 'arrow-top-right' : 'arrow-bottom-left';
    const iconColor = isExpense ? '#ef4444' : '#10b981';

    return (
        <TouchableOpacity
            className={`flex-row items-center p-4 mb-2 rounded-xl border ${themeClasses.bg.surface} ${themeClasses.border}`}
            onPress={onUpdate}
        >
            <View className={`w-10 h-10 rounded-full items-center justify-center mr-3 ${themeClasses.bg.surfaceVariant}`}>
                <MaterialCommunityIcons name={iconName} size={20} color={iconColor} />
            </View>

            <View className="flex-1 mr-2">
                <Text className={`text-base font-semibold ${themeClasses.text.primary}`} numberOfLines={1}>
                    {transaction.title}
                </Text>
                <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>
                    {transaction.category} • {new Date(transaction.date).toLocaleDateString()}
                </Text>
            </View>

            <View className="items-end">
                <Text className={`text-base font-bold ${amountColor}`}>
                    {isExpense ? '-' : '+'}{currency.symbol}{transaction.amount.toFixed(2)}
                </Text>
                {transaction.accountId && (
                    <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>
                        {/* We could lookup account name here if needed */}
                        Account
                    </Text>
                )}
            </View>
        </TouchableOpacity>
    );
};

export default TransactionListItem;
