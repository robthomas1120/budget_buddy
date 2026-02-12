import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Account } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface AccountListItemProps {
    account: Account;
    onPress: () => void;
}

const AccountListItem: React.FC<AccountListItemProps> = ({ account, onPress }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    const getIconName = (type: string): keyof typeof MaterialCommunityIcons.glyphMap => {
        switch (type.toLowerCase()) {
            case 'bank': return 'bank';
            case 'cash': return 'wallet';
            case 'e-wallet': return 'cellphone';
            default: return 'cash';
        }
    };

    return (
        <TouchableOpacity
            onPress={onPress}
            className={`p-4 mb-2 rounded-lg ${themeClasses.bg.surface} border ${themeClasses.border} flex-row items-center`}
            activeOpacity={0.7}
        >
            <View className={`w-12 h-12 rounded-full items-center justify-center mr-3 ${themeClasses.bg.surfaceVariant}`}>
                <MaterialCommunityIcons
                    name={getIconName(account.type)}
                    size={24}
                    color={theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899'}
                />
            </View>

            <View className="flex-1">
                <Text className={`text-base font-semibold ${themeClasses.text.primary}`}>
                    {account.name}
                </Text>
                <Text className={`text-sm ${themeClasses.text.secondary} mt-0.5 capitalize`}>
                    {account.type}
                </Text>
            </View>

            <Text className={`text-lg font-bold ${themeClasses.text.primary}`}>
                ₱{account.balance.toFixed(2)}
            </Text>
        </TouchableOpacity>
    );
};

export default AccountListItem;
