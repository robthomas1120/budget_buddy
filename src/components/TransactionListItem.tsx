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
    isOutflow?: boolean;
}

const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, onDelete, onUpdate, isOutflow }) => {
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const type = transaction.type;
    const isActuallyOutflow = isOutflow !== undefined ? isOutflow : (type === 'expense');

    // Icon and Color logic
    let iconName: any = 'swap-horizontal';
    let iconColor = '#3b82f6'; // Blue for transfer
    let amountColor = 'text-blue-500';

    if (type === 'expense') {
        iconName = 'arrow-top-right';
        iconColor = '#ef4444';
        amountColor = 'text-red-500';
    } else if (type === 'income') {
        iconName = 'arrow-bottom-left';
        iconColor = '#10b981';
        amountColor = 'text-green-500';
    } else if (type === 'transfer') {
        // Use custom sign color if provided, otherwise stick to neutral blue
        if (isOutflow !== undefined) {
            amountColor = isActuallyOutflow ? 'text-red-500' : 'text-green-500';
        } else {
            amountColor = 'text-blue-500';
            iconColor = '#3b82f6';
        }
    }

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
                    {type.charAt(0).toUpperCase() + type.slice(1)} • {new Date(transaction.date).toLocaleDateString()}
                </Text>
            </View>

            <View className="items-end">
                <Text className={`text-base font-bold ${amountColor}`}>
                    {type === 'transfer' && isOutflow === undefined ? '' : (isActuallyOutflow ? '-' : '+')}
                    {currency.symbol}{transaction.amount.toFixed(2)}
                </Text>
                <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>
                    {transaction.category || (type === 'transfer' ? 'Transfer' : 'Other')}
                </Text>
            </View>
        </TouchableOpacity>
    );
};

export default TransactionListItem;
