import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Budget } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';

interface BudgetListItemProps {
    budget: Budget;
    onPress: () => void;
}

const BudgetListItem: React.FC<BudgetListItemProps> = ({ budget, onPress }) => {
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const progress = Math.min((budget.spent / budget.amount) * 100, 100);
    const isOverBudget = budget.spent > budget.amount;

    return (
        <TouchableOpacity
            onPress={onPress}
            className={`p-4 mb-3 rounded-xl ${themeClasses.bg.surface} border ${themeClasses.border}`}
            activeOpacity={0.7}
        >
            <View className="flex-row justify-between items-center">
                <View className="flex-1">
                    <Text className={`text-lg font-bold ${themeClasses.text.primary}`}>
                        {budget.title}
                    </Text>
                    <Text className={`text-xs ${themeClasses.text.secondary} mt-0.5`}>
                        Budget Wallet
                    </Text>
                </View>
                <View className="items-end">
                    <Text className={`text-xl font-bold ${budget.spent >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {currency.symbol}{budget.spent.toFixed(2)}
                    </Text>
                    <Text className={`text-[10px] ${themeClasses.text.secondary}`}>
                        Current Balance
                    </Text>
                </View>
            </View>
        </TouchableOpacity>
    );
};

export default BudgetListItem;
