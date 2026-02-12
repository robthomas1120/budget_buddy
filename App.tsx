import React, { useEffect, useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import AppNavigator from './src/navigation/AppNavigator';
import { AppProvider } from './src/context/AppContext';
import { ThemeProvider } from './src/context/ThemeContext';
import { initDatabase } from './src/database/DatabaseHelper';

import { CurrencyProvider } from './src/context/CurrencyContext';

export default function App() {
  const [dbReady, setDbReady] = useState(false);

  useEffect(() => {
    const loadApp = async () => {
      try {
        await initDatabase();
        setDbReady(true);
      } catch (error) {
        console.error('Failed to load data:', error);
      }
    };
    loadApp();
  }, []);

  if (!dbReady) {
    return <View />;
  }

  return (
    <ThemeProvider>
      <CurrencyProvider>
        <AppProvider>
          <NavigationContainer>
            <AppNavigator />
            <StatusBar style="auto" />
          </NavigationContainer>
        </AppProvider>
      </CurrencyProvider>
    </ThemeProvider>
  );
}
