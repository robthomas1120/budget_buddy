import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { NavigationContainer } from '@react-navigation/native';
import { IconButton } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';

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
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: true,
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
  return (
    <NavigationContainer>
      <Stack.Navigator>
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
    </NavigationContainer>
  );
};

export default AppNavigator;
