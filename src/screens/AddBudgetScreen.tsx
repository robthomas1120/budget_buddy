import React, { useState } from 'react';
import { View, Text, ScrollView, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { insertBudget } from '../database/BudgetHelper';
import { useCurrency } from '../context/CurrencyContext';

const AddBudgetScreen = () => {
    const navigation = useNavigation();
    const { refreshData, db } = useApp();
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);

    const [title, setTitle] = useState('');
    const [amount, setAmount] = useState('');
    const [category, setCategory] = useState('Food');
    const [period, setPeriod] = useState('Monthly');

    const categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Health', 'Education', 'Other'];
    const periods = ['Weekly', 'Monthly', 'Yearly', 'One-time'];

    const handleSave = async () => {
        if (!title || !amount || !db) {
            Alert.alert('Error', 'Please fill in all fields');
            return;
        }

        const parsedAmount = parseFloat(amount);
        if (isNaN(parsedAmount) || parsedAmount <= 0) {
            Alert.alert('Error', 'Invalid amount');
            return;
        }

        try {
            await insertBudget(db, {
                title,
                amount: parsedAmount,
                spent: 0,
                category,
                period,
                startDate: Date.now(),
                endDate: Date.now() + 30 * 24 * 60 * 60 * 1000, // approx 1 month
                isActive: true
            });

            await refreshData();
            navigation.goBack();
        } catch (error) {
            console.error(error);
            Alert.alert('Error', 'Failed to save budget');
        }
    };

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            <ScrollView className="p-4">

                {/* Title Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Budget Name</Text>
                    <TextInput
                        value={title}
                        onChangeText={setTitle}
                        placeholder="e.g. Monthly Groceries"
                        placeholderTextColor="#9CA3AF"
                        className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                    />
                </View>

                {/* Amount Input */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Limit Amount</Text>
                    <View className={`flex-row items-center border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface}`}>
                        <Text className={`text-lg font-bold mr-2 ${themeClasses.text.primary}`}>{currency.symbol}</Text>
                        <TextInput
                            value={amount}
                            onChangeText={setAmount}
                            keyboardType="numeric"
                            placeholder="0.00"
                            placeholderTextColor="#9CA3AF"
                            className={`flex-1 text-xl font-bold ${themeClasses.text.primary}`}
                        />
                    </View>
                </View>

                {/* Category Selector */}
                <View className="mb-4">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Category</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row">
                        {categories.map(cat => (
                            <TouchableOpacity
                                key={cat}
                                onPress={() => setCategory(cat)}
                                className={`mr-2 px-4 py-2 rounded-full border ${category === cat ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                                style={category === cat ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                            >
                                <Text className={`${category === cat ? 'font-bold' : ''} ${themeClasses.text.primary}`}
                                    style={category === cat ? { color: primaryColor } : {}}>
                                    {cat}
                                </Text>
                            </TouchableOpacity>
                        ))}
                    </ScrollView>
                </View>

                {/* Period Selector */}
                <View className="mb-6">
                    <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>Period</Text>
                    <View className="flex-row flex-wrap">
                        {periods.map(p => (
                            <TouchableOpacity
                                key={p}
                                onPress={() => setPeriod(p)}
                                className={`mr-2 mb-2 px-4 py-2 rounded-full border ${period === p ? 'bg-opacity-20' : themeClasses.bg.surface} ${themeClasses.border}`}
                                style={period === p ? { backgroundColor: primaryColor + '30', borderColor: primaryColor } : {}}
                            >
                                <Text className={`${period === p ? 'font-bold' : ''} ${themeClasses.text.primary}`}
                                    style={period === p ? { color: primaryColor } : {}}>
                                    {p}
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
                    <Text className="text-white font-bold text-lg">Create Budget</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default AddBudgetScreen;
