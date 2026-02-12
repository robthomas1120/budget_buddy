import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Budget } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface BudgetListItemProps {
    budget: Budget;
    onPress: () => void;
}

const BudgetListItem: React.FC<BudgetListItemProps> = ({ budget, onPress }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    const progress = Math.min((budget.spent / budget.amount) * 100, 100);
    const isOverBudget = budget.spent > budget.amount;

    return (
        <TouchableOpacity
            onPress={onPress}
            className={`p-4 mb-3 rounded-xl ${themeClasses.bg.surface} border ${themeClasses.border}`}
            activeOpacity={0.7}
        >
            <View className="flex-row justify-between items-start mb-2">
                <View className="flex-1">
                    <Text className={`text-lg font-bold ${themeClasses.text.primary}`}>
                        {budget.title}
                    </Text>
                    <Text className={`text-sm ${themeClasses.text.secondary} mt-0.5`}>
                        {budget.category} • {budget.period}
                    </Text>
                </View>
                <Text className={`text-base font-semibold ${isOverBudget ? 'text-red-600' : themeClasses.text.secondary}`}>
                    ₱{budget.spent.toFixed(2)} / ₱{budget.amount.toFixed(2)}
                </Text>
            </View>

            {/* Progress Bar */}
            <View className={`h-2 rounded-full ${themeClasses.bg.surfaceVariant} overflow-hidden`}>
                <View
                    className={`h-full ${isOverBudget ? 'bg-red-500' : 'bg-green-500'}`}
                    style={{ width: `${progress}%` }}
                />
            </View>

            <Text className={`text-xs ${themeClasses.text.secondary} mt-1.5`}>
                {isOverBudget ? `Over budget by ₱${(budget.spent - budget.amount).toFixed(2)}` : `₱${(budget.amount - budget.spent).toFixed(2)} remaining`}
            </Text>
        </TouchableOpacity>
    );
};

export default BudgetListItem;
