import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useAppTheme } from '../context/ThemeContext';

import DashboardScreen from '../screens/DashboardScreen';
import BudgetScreen from '../screens/BudgetScreen';
import AccountsScreen from '../screens/AccountsScreen';
import SavingsScreen from '../screens/SavingsScreen';
import AddTransactionScreen from '../screens/AddTransactionScreen';
import AddBudgetScreen from '../screens/AddBudgetScreen';
import AddAccountScreen from '../screens/AddAccountScreen';
import AddSavingsGoalScreen from '../screens/AddSavingsGoalScreen';
import SettingsScreen from '../screens/SettingsScreen';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

const TabNavigator = () => {
  const { theme } = useAppTheme();

  const getColors = () => {
    switch (theme) {
      case 'dark':
        return {
          primary: '#10b981',
          background: '#111827',
          card: '#1f2937',
          text: '#f9fafb',
          border: '#374151',
        };
      case 'dark-pink':
        return {
          primary: '#ec4899',
          background: '#18181b',
          card: '#27272a',
          text: '#fafafa',
          border: '#3f3f46',
        };
      default: // light
        return {
          primary: '#10b981',
          background: '#ffffff',
          card: '#f9fafb',
          text: '#111827',
          border: '#e5e7eb',
        };
    }
  };

  const colors = getColors();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: true,
        headerStyle: {
          backgroundColor: colors.card,
        },
        headerTintColor: colors.text,
        tabBarStyle: {
          backgroundColor: colors.card,
          borderTopColor: colors.border,
        },
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.text,
        tabBarIcon: ({ color, size }) => {
          let iconName: keyof typeof MaterialCommunityIcons.glyphMap = 'home';

          if (route.name === 'Dashboard') {
            iconName = 'view-dashboard';
          } else if (route.name === 'Budgets') {
            iconName = 'wallet';
          } else if (route.name === 'Savings') {
            iconName = 'piggy-bank';
          } else if (route.name === 'Settings') {
            iconName = 'cog';
          }

          return <MaterialCommunityIcons name={iconName} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Dashboard" component={DashboardScreen} />
      <Tab.Screen name="Budgets" component={BudgetScreen} />
      <Tab.Screen name="Savings" component={SavingsScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
};

const AppNavigator = () => {
  const { theme } = useAppTheme();

  const getColors = () => {
    switch (theme) {
      case 'dark':
        return {
          primary: '#10b981',
          background: '#111827',
          card: '#1f2937',
          text: '#f9fafb',
          border: '#374151',
        };
      case 'dark-pink':
        return {
          primary: '#ec4899',
          background: '#18181b',
          card: '#27272a',
          text: '#fafafa',
          border: '#3f3f46',
        };
      default: // light
        return {
          primary: '#10b981',
          background: '#ffffff',
          card: '#f9fafb',
          text: '#111827',
          border: '#e5e7eb',
        };
    }
  };

  const colors = getColors();

  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: colors.card,
        },
        headerTintColor: colors.text,
        contentStyle: {
          backgroundColor: colors.background,
        },
      }}
    >
      <Stack.Screen
        name="Root"
        component={TabNavigator}
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="Accounts"
        component={AccountsScreen}
        options={{ title: 'My Accounts' }}
      />
      <Stack.Screen
        name="AddTransaction"
        component={AddTransactionScreen}
        options={{ presentation: 'modal', title: 'Add Transaction' }}
      />
      <Stack.Screen
        name="AddBudget"
        component={AddBudgetScreen}
        options={{ presentation: 'modal', title: 'Create Budget' }}
      />
      <Stack.Screen
        name="AddAccount"
        component={AddAccountScreen}
        options={{ presentation: 'modal', title: 'Add Account' }}
      />
      <Stack.Screen
        name="AddSavingsGoal"
        component={AddSavingsGoalScreen}
        options={{ presentation: 'modal', title: 'New Savings Goal' }}
      />
    </Stack.Navigator>
  );
};

export default AppNavigator;
