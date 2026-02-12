import React, { useState } from 'react';
import { View, Text, ScrollView, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { insertAccount } from '../database/AccountHelper';
import { useCurrency } from '../context/CurrencyContext';

const AddAccountScreen = () => {
    const navigation = useNavigation();
    const { refreshData, db } = useApp();
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const [name, setName] = useState('');
    const [balance, setBalance] = useState('');
    const [type, setType] = useState('Cash');

    const types = ['Cash', 'Bank', 'E-Wallet', 'Credit Card', 'Investment'];

    const handleSave = async () => {
        if (!name || !balance || !db) {
            Alert.alert('Error', 'Please fill in all fields');
            return;
        }

        const parsedBalance = parseFloat(balance);
        if (isNaN(parsedBalance)) {
            Alert.alert('Error', 'Invalid balance');
            return;
        }

        try {
            await insertAccount(db, {
                name,
                balance: parsedBalance,
                type
            });

            await refreshData();
            navigation.goBack();
        } catch (error) {
            console.error(error);
            Alert.alert('Error', 'Failed to save account');
        }
    };

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            <ScrollView className="p-4">

                {/* Name Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Account Name</Text>
                    <TextInput
                        value={name}
                        onChangeText={setName}
                        placeholder="e.g. BPI Savings"
                        placeholderTextColor="#9CA3AF"
                        className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                    />
                </View>

                {/* Balance Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Current Balance</Text>
                    <View className={`flex-row items-center border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface}`}>
                        <Text className={`text-lg font-bold mr-2 ${themeClasses.text.primary}`}>{currency.symbol}</Text>
                        <TextInput
                            value={balance}
                            onChangeText={setBalance}
                            keyboardType="numeric"
                            placeholder="0.00"
                            placeholderTextColor="#9CA3AF"
                            className={`flex-1 text-xl font-bold ${themeClasses.text.primary}`}
                        />
                    </View>
                </View>

                {/* Type Selector */}
                <View className="mb-6">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Account Type</Text>
                    <View className="flex-row flex-wrap">
                        {types.map(t => (
                            <TouchableOpacity
                                key={t}
                                onPress={() => setType(t)}
                                className={`mr-2 mb-2 px-4 py-2 rounded-full border ${type === t ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                                style={type === t ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                            >
                                <Text className={`${type === t ? 'font-bold' : ''} ${themeClasses.text.primary}`}
                                    style={type === t ? { color: primaryColor } : {}}>
                                    {t}
                                </Text>
                            </TouchableOpacity>
                        ))}
                    </View>
                </View>

            </ScrollView>

            <View className={`p-4 border-t ${themeClasses.border} ${themeClasses.bg.surface}`}>
                <TouchableOpacity
                    onPress={handleSave}
                    className="py-4 rounded-xl items-center shadow-sm"
                    style={{ backgroundColor: primaryColor }}
                >
                    <Text className="text-white font-bold text-lg">Add Account</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default AddAccountScreen;
