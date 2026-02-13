// Theme type definition
export type ThemeType = 'light' | 'dark' | 'dark-pink';

interface ThemeDefinition {
    bg: {
        primary: string;
        surface: string;
        surfaceVariant: string;
        background: string;
    };
    text: {
        primary: string;
        secondary: string;
        onPrimary: string;
        accent?: string;
    };
    raw: {
        textSecondary: string;
    };
    border: string;
}

// Theme class mappings for NativeWind
export const themeClasses: Record<ThemeType, ThemeDefinition> = {
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
        raw: {
            textSecondary: '#6b7280',
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
        raw: {
            textSecondary: '#9ca3af',
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
        raw: {
            textSecondary: '#a1a1aa',
        },
        border: 'border-pink-border',
    },
};

// Helper to get theme classes
export const getThemeClasses = (theme: ThemeType): ThemeDefinition => themeClasses[theme];
