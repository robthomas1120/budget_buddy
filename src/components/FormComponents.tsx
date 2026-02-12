// Simple form components for NativeWind
import React from 'react';
import { View, Text, TextInput as RNTextInput, TouchableOpacity, TextInputProps } from 'react-native';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';

interface CustomInputProps extends TextInputProps {
    label: string;
    error?: string;
}

export const Input: React.FC<CustomInputProps> = ({ label, error, ...props }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    return (
        <View className="mb-4">
            <Text className={`text-sm font-semibold mb-1.5 ${themeClasses.text.primary}`}>
                {label}
            </Text>
            <RNTextInput
                {...props}
                className={`border rounded-lg px-3 py-3 ${themeClasses.border} ${themeClasses.bg.surface} ${themeClasses.text.primary}`}
                placeholderTextColor={theme === 'light' ? '#9CA3AF' : '#6B7280'}
            />
            {error && (
                <Text className="text-red-500 text-xs mt-1">{error}</Text>
            )}
        </View>
    );
};

interface ButtonProps {
    title: string;
    onPress: () => void;
    variant?: 'primary' | 'secondary' | 'outline';
    disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ title, onPress, variant = 'primary', disabled = false }) => {
    const { theme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);
    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    const getStyles = () => {
        if (variant === 'outline') {
            return `border-2 ${disabled ? 'opacity-50' : ''}`;
        }
        if (variant === 'secondary') {
            return `${themeClasses.bg.surfaceVariant} ${disabled ? 'opacity-50' : ''}`;
        }
        return disabled ? 'opacity-50' : '';
    };

    return (
        <TouchableOpacity
            onPress={onPress}
            disabled={disabled}
            className={`py-3 px-4 rounded-lg items-center ${getStyles()}`}
            style={variant === 'primary' && !disabled ? { backgroundColor: primaryColor } :
                variant === 'outline' ? { borderColor: primaryColor } : {}}
        >
            <Text className={`font-semibold ${variant === 'primary' ? 'text-white' :
                    variant === 'outline' ? themeClasses.text.primary :
                        themeClasses.text.primary
                }`} style={variant === 'outline' ? { color: primaryColor } : {}}>
                {title}
            </Text>
        </TouchableOpacity>
    );
};
