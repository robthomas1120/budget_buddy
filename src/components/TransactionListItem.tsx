import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Transaction } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface TransactionListItemProps {
    transaction: Transaction;
    onDelete: () => void;
    onUpdate: () => void;
}

const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, onDelete, onUpdate }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);
    const isIncome = transaction.type === 'income';

    return (
        <TouchableOpacity
            onPress={onUpdate}
            className={`p-4 mb-2 rounded-lg ${themeClasses.bg.surface} border ${themeClasses.border}`}
            activeOpacity={0.7}
        >
            <View className="flex-row justify-between items-start">
                <View className="flex-1">
                    <Text className={`text-base font-semibold ${themeClasses.text.primary}`}>
                        {transaction.title}
                    </Text>
                    <Text className={`text-sm ${themeClasses.text.secondary} mt-0.5`}>
                        {transaction.category} • {new Date(transaction.date).toLocaleDateString()}
                    </Text>
                </View>

                <View className="items-end">
                    <Text className={`text-lg font-bold ${isIncome ? 'text-green-600' : 'text-red-600'}`}>
                        {isIncome ? '+' : '-'}₱{transaction.amount.toFixed(2)}
                    </Text>
                    <TouchableOpacity
                        onPress={onDelete}
                        className="mt-1"
                        hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                    >
                        <MaterialCommunityIcons
                            name="delete-outline"
                            size={20}
                            color="#ef4444"
                        />
                    </TouchableOpacity>
                </View>
            </View>
        </TouchableOpacity>
    );
};

export default TransactionListItem;
