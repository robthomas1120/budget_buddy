import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import AccountListItem from '../components/AccountListItem';

const AccountsScreen = () => {
  const { accounts } = useApp();
  const { theme } = useAppTheme();
  const themeClasses = getThemeClasses(theme);
  const navigation = useNavigation<any>();

  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);
  const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

  return (
    <View className={`flex-1 ${themeClasses.bg.background}`}>
      <ScrollView className="p-4 pb-20">
        <View className={`p-5 rounded-xl mb-4 items-center`} style={{ backgroundColor: primaryColor }}>
          <Text className="text-white/90 text-base mb-1">Total Balance</Text>
          <Text className="text-white text-3xl font-bold">₱{totalBalance.toFixed(2)}</Text>
        </View>

        <Text className={`text-xl font-bold mb-3 ${themeClasses.text.primary}`}>
          Your Accounts
        </Text>

        {accounts.length === 0 ? (
          <View className="items-center py-20">
            <MaterialCommunityIcons
              name="bank-outline"
              size={64}
              color={theme === 'light' ? '#D1D5DB' : '#4B5563'}
            />
            <Text className={`text-lg ${themeClasses.text.secondary} mt-4`}>
              No accounts yet
            </Text>
            <Text className={`text-sm ${themeClasses.text.secondary} text-center mt-2 px-6`}>
              Add your first account to start tracking
            </Text>
          </View>
        ) : (
          accounts.map(account => (
            <AccountListItem
              key={account.id}
              account={account}
              onPress={() => {
                // Navigate to account details if needed
              }}
            />
          ))
        )}
      </ScrollView>

      <View className="absolute bottom-5 right-5">
        <TouchableOpacity
          onPress={() => navigation.navigate('AddAccount')}
          className="w-14 h-14 rounded-full items-center justify-center shadow-lg"
          style={{ backgroundColor: primaryColor }}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default AccountsScreen;
