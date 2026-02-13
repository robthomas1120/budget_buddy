import React, { useState } from 'react';
import { View, Text, ScrollView, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { insertSavingsGoal } from '../database/SavingsHelper';
import { useCurrency } from '../context/CurrencyContext';

const AddSavingsGoalScreen = () => {
    const navigation = useNavigation();
    const { refreshData, db } = useApp();
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const [name, setName] = useState('');
    const [targetAmount, setTargetAmount] = useState('');
    const [reason, setReason] = useState('');

    const handleSave = async () => {
        if (!name || !targetAmount || !db) {
            Alert.alert('Error', 'Please fill in all fields');
            return;
        }

        const parsedAmount = parseFloat(targetAmount);
        if (isNaN(parsedAmount) || parsedAmount <= 0) {
            Alert.alert('Error', 'Invalid target amount');
            return;
        }

        try {
            await insertSavingsGoal(db, {
                name,
                targetAmount: parsedAmount,
                currentAmount: 0,
                reason,
                startDate: Date.now(),
                targetDate: Date.now() + 30 * 24 * 60 * 60 * 1000, // Default 1 month
                isActive: true
            });

            await refreshData();
            navigation.goBack();
        } catch (error) {
            console.error(error);
            Alert.alert('Error', 'Failed to save goal');
        }
    };

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            <ScrollView className="p-4">

                {/* Name Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Goal Name</Text>
                    <TextInput
                        value={name}
                        onChangeText={setName}
                        placeholder="e.g. New Laptop"
                        placeholderTextColor="#9CA3AF"
                        className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                    />
                </View>

                {/* Target Amount Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Target Amount</Text>
                    <View className={`flex-row items-center border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface}`}>
                        <Text className={`text-lg font-bold mr-2 ${themeClasses.text.primary}`}>{currency.symbol}</Text>
                        <TextInput
                            value={targetAmount}
                            onChangeText={setTargetAmount}
                            keyboardType="numeric"
                            placeholder="0.00"
                            placeholderTextColor="#9CA3AF"
                            className={`flex-1 text-xl font-bold ${themeClasses.text.primary}`}
                        />
                    </View>
                </View>

                {/* Reason Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Reason (Optional)</Text>
                    <TextInput
                        value={reason}
                        onChangeText={setReason}
                        placeholder="Why are you saving for this?"
                        placeholderTextColor="#9CA3AF"
                        multiline
                        numberOfLines={3}
                        className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                        style={{ textAlignVertical: 'top' }}
                    />
                </View>

            </ScrollView>

            <View className={`p-4 pb-10 border-t ${themeClasses.border} ${themeClasses.bg.surface}`}>
                <TouchableOpacity
                    onPress={handleSave}
                    className="py-4 rounded-xl items-center shadow-sm"
                    style={{ backgroundColor: primaryColor }}
                >
                    <Text className="text-white font-bold text-lg">Create Goal</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default AddSavingsGoalScreen;
