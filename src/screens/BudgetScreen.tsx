import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import BudgetListItem from '../components/BudgetListItem';

const BudgetScreen = () => {
  const { budgets } = useApp();
  const { theme } = useAppTheme();
  const themeClasses = getThemeClasses(theme);
  const navigation = useNavigation<any>();

  const activeBudgets = budgets.filter(b => b.isActive);
  const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

  return (
    <View className={`flex-1 ${themeClasses.bg.background}`}>
      <ScrollView className="p-4 pb-20">
        {activeBudgets.length === 0 ? (
          <View className="items-center py-20">
            <MaterialCommunityIcons
              name="wallet-outline"
              size={64}
              color={theme === 'light' ? '#D1D5DB' : '#4B5563'}
            />
            <Text className={`text-lg ${themeClasses.text.secondary} mt-4`}>
              No budgets yet
            </Text>
            <Text className={`text-sm ${themeClasses.text.secondary} text-center mt-2 px-6`}>
              Create a budget to track your spending
            </Text>
          </View>
        ) : (
          activeBudgets.map(budget => (
            <BudgetListItem
              key={budget.id}
              budget={budget}
              onPress={() => {
                navigation.navigate('BudgetDetails', { budgetId: budget.id, title: budget.title });
              }}
            />
          ))
        )}
      </ScrollView>

      <View className="absolute bottom-5 right-5">
        <TouchableOpacity
          onPress={() => navigation.navigate('AddBudget')}
          className="w-14 h-14 rounded-full items-center justify-center shadow-lg"
          style={{ backgroundColor: primaryColor }}
        >
          <MaterialCommunityIcons name="plus" size={30} color="white" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default BudgetScreen;
