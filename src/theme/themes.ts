// Theme type definition
export type ThemeType = 'light' | 'dark' | 'dark-pink';

// Theme class mappings for NativeWind
export const themeClasses = {
    light: {
        bg: {
            primary: 'bg-light-primary',
            surface: 'bg-light-surface',
            surfaceVariant: 'bg-light-surfaceVariant',
            background: 'bg-light-background',
        },
        text: {
            primary: 'text-light-text',
            secondary: 'text-light-textSecondary',
            onPrimary: 'text-white',
        },
        border: 'border-light-border',
    },
    dark: {
        bg: {
            primary: 'bg-dark-primary',
            surface: 'bg-dark-surface',
            surfaceVariant: 'bg-dark-surfaceVariant',
            background: 'bg-dark-background',
        },
        text: {
            primary: 'text-dark-text',
            secondary: 'text-dark-textSecondary',
            onPrimary: 'text-white',
        },
        border: 'border-dark-border',
    },
    'dark-pink': {
        bg: {
            primary: 'bg-pink-primary',
            surface: 'bg-pink-surface',
            surfaceVariant: 'bg-pink-surfaceVariant',
            background: 'bg-pink-background',
        },
        text: {
            primary: 'text-pink-text',
            secondary: 'text-pink-textSecondary',
            onPrimary: 'text-white',
            accent: 'text-pink-accent',
        },
        border: 'border-pink-border',
    },
};

// Helper to get theme classes
export const getThemeClasses = (theme: ThemeType) => themeClasses[theme];
