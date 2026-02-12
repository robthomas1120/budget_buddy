import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';

interface BalanceSummaryCardProps {
    currentBalance: number;
    onBalanceTap?: () => void;
}

const BalanceSummaryCard: React.FC<BalanceSummaryCardProps> = ({ currentBalance, onBalanceTap }) => {
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const [isBalanceVisible, setIsBalanceVisible] = React.useState(true);
    const themeClasses = getThemeClasses(theme);

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    const toggleBalanceVisibility = () => {
        setIsBalanceVisible(!isBalanceVisible);
    };

    return (
        <TouchableOpacity
            onPress={onBalanceTap}
            activeOpacity={0.9}
            className="rounded-2xl p-6 mb-4 shadow-lg"
            style={{ backgroundColor: primaryColor }}
        >
            <View className="mb-2">
                <Text className="text-white/80 text-sm font-medium uppercase tracking-wider mb-1">
                    Total Balance
                </Text>

                <View className="flex-row items-center justify-between">
                    <Text className="text-white text-4xl font-bold">
                        {isBalanceVisible ? `${currency.symbol}${currentBalance.toFixed(2)}` : '••••••'}
                    </Text>

                    <TouchableOpacity
                        onPress={toggleBalanceVisibility}
                        hitSlop={{ top: 15, bottom: 15, left: 15, right: 15 }}
                        className="bg-white/20 p-2 rounded-full"
                    >
                        <MaterialCommunityIcons
                            name={isBalanceVisible ? "eye" : "eye-off"}
                            size={32}
                            color="rgba(255,255,255,0.9)"
                        />
                    </TouchableOpacity>
                </View>
            </View>


        </TouchableOpacity>
    );
};

export default BalanceSummaryCard;
