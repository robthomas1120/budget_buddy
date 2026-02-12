import React, { createContext, useContext, useState, useEffect } from 'react';
import { useColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Provider as PaperProvider } from 'react-native-paper';
import { lightTheme, darkTheme, darkPinkTheme } from '../theme/themes';

type ThemeType = 'light' | 'dark' | 'dark-pink';

interface ThemeContextType {
    themeType: ThemeType;
    setThemeType: (type: ThemeType) => void;
    theme: any;
}

const ThemeContext = createContext<ThemeContextType>({
    themeType: 'light',
    setThemeType: () => { },
    theme: lightTheme,
});

export const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
    const systemScheme = useColorScheme();
    const [themeType, setThemeType] = useState<ThemeType>('light');

    useEffect(() => {
        loadTheme();
    }, []);

    const loadTheme = async () => {
        try {
            const savedTheme = await AsyncStorage.getItem('user_theme');
            if (savedTheme) {
                setThemeType(savedTheme as ThemeType);
            } else if (systemScheme) {
                setThemeType(systemScheme as ThemeType);
            }
        } catch (error) {
            console.log('Failed to load theme', error);
        }
    };

    const saveTheme = async (type: ThemeType) => {
        try {
            await AsyncStorage.setItem('user_theme', type);
            setThemeType(type);
        } catch (error) {
            console.log('Failed to save theme', error);
        }
    };

    const getTheme = () => {
        switch (themeType) {
            case 'dark':
                return darkTheme;
            case 'dark-pink':
                return darkPinkTheme;
            default:
                return lightTheme;
        }
    };

    return (
        <ThemeContext.Provider value={{ themeType, setThemeType: saveTheme, theme: getTheme() }}>
            <PaperProvider theme={getTheme()}>
                {children}
            </PaperProvider>
        </ThemeContext.Provider>
    );
};

export const useAppTheme = () => useContext(ThemeContext);
