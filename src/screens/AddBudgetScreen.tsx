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

    const handleSave = async () => {
        if (!title || !db) {
            Alert.alert('Error', 'Please enter a budget name');
            return;
        }

        try {
            await insertBudget(db, {
                title,
                amount: 0, // No longer used as a limit
                spent: 0,
                category: 'General',
                period: 'monthly',
                startDate: Date.now(),
                endDate: Date.now(),
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
                        placeholder="e.g. Rainy Day Fund"
                        placeholderTextColor="#9CA3AF"
                        className={`border rounded-xl px-4 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                    />
                    <Text className={`text-xs ${themeClasses.text.secondary} mt-2`}>
                        This budget will track income and expenses linked to it.
                    </Text>
                </View>

            </ScrollView>

            <View className={`p-4 pb-10 border-t ${themeClasses.border} ${themeClasses.bg.surface}`}>
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
