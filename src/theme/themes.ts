import { MD3LightTheme, MD3DarkTheme } from 'react-native-paper';

export const lightTheme = {
    ...MD3LightTheme,
    colors: {
        ...MD3LightTheme.colors,
        primary: '#6200ee',
        secondary: '#03dac6',
        background: '#ffffff',
        surface: '#f6f6f6',
    },
};

export const darkTheme = {
    ...MD3DarkTheme,
    colors: {
        ...MD3DarkTheme.colors,
        primary: '#bb86fc',
        secondary: '#03dac6',
        background: '#121212',
        surface: '#121212',
    },
};

export const darkPinkTheme = {
    ...MD3DarkTheme,
    colors: {
        ...MD3DarkTheme.colors,
        primary: '#ff80ab', // Pink accent
        secondary: '#ff4081',
        background: '#1a000d', // Very dark pink/black
        surface: '#2d0016', // Slightly lighter dark pink
        onSurface: '#ffcfe5',
    },
};
