import React, { useState } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface BalanceSummaryCardProps {
    currentBalance: number;
    onBalanceTap: () => void;
}

const BalanceSummaryCard: React.FC<BalanceSummaryCardProps> = ({ currentBalance, onBalanceTap }) => {
    const [isBalanceVisible, setIsBalanceVisible] = useState(false);
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    return (
        <View className={`p-5 rounded-xl my-2.5 ${themeClasses.bg.primary}`}>
            <View className="flex-row items-center justify-between">
                <TouchableOpacity onPress={onBalanceTap} activeOpacity={0.9} className="flex-1 justify-center">
                    <Text className={`text-base mb-1 ${themeClasses.text.onPrimary} opacity-90`}>
                        Current Balance
                    </Text>
                    <Text className={`text-3xl font-bold ${themeClasses.text.onPrimary}`}>
                        {isBalanceVisible ? `₱${currentBalance.toFixed(2)}` : '₱ ******'}
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    onPress={() => setIsBalanceVisible(!isBalanceVisible)}
                    className="pl-2.5 justify-center"
                    hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                >
                    <MaterialCommunityIcons
                        name={isBalanceVisible ? "eye-off" : "eye"}
                        size={28}
                        color="white"
                    />
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default BalanceSummaryCard;
