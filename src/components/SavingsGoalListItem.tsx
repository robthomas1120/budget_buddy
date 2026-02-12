import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SavingsGoal } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface SavingsGoalListItemProps {
    goal: SavingsGoal;
    onPress: () => void;
    onDeposit: () => void;
}

const SavingsGoalListItem: React.FC<SavingsGoalListItemProps> = ({ goal, onPress, onDeposit }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    const progress = Math.min((goal.currentAmount / goal.targetAmount) * 100, 100);
    const remaining = Math.max(goal.targetAmount - goal.currentAmount, 0);

    return (
        <TouchableOpacity
            onPress={onPress}
            className={`p-4 mb-3 rounded-xl ${themeClasses.bg.surface} border ${themeClasses.border}`}
            activeOpacity={0.7}
        >
            <View className="flex-row justify-between items-start mb-3">
                <View className="flex-1">
                    <Text className={`text-lg font-bold ${themeClasses.text.primary}`}>
                        {goal.name}
                    </Text>
                    {goal.reason && (
                        <Text className={`text-sm ${themeClasses.text.secondary} mt-0.5`}>
                            {goal.reason}
                        </Text>
                    )}
                </View>
                <TouchableOpacity
                    onPress={onDeposit}
                    className={`px-3 py-1.5 rounded-lg flex-row items-center ${theme === 'dark-pink' ? 'bg-pink-primary' : 'bg-green-500'}`}
                    activeOpacity={0.7}
                >
                    <MaterialCommunityIcons name="plus" size={16} color="white" />
                    <Text className="text-white font-semibold ml-1">Deposit</Text>
                </TouchableOpacity>
            </View>

            <View className="flex-row justify-between items-center mb-2">
                <Text className={`text-base font-bold ${themeClasses.text.primary}`}>
                    ₱{goal.currentAmount.toFixed(2)}
                </Text>
                <Text className={`text-sm ${themeClasses.text.secondary}`}>
                    / ₱{goal.targetAmount.toFixed(2)}
                </Text>
            </View>

            {/* Progress Bar */}
            <View className={`h-2.5 rounded-full ${themeClasses.bg.surfaceVariant} overflow-hidden mb-1.5`}>
                <View
                    className={theme === 'dark-pink' ? 'bg-pink-accent' : 'bg-green-500'}
                    style={{ width: `${progress}%`, height: '100%' }}
                />
            </View>

            <Text className={`text-xs ${themeClasses.text.secondary}`}>
                ₱{remaining.toFixed(2)} to go
            </Text>
        </TouchableOpacity>
    );
};

export default SavingsGoalListItem;
