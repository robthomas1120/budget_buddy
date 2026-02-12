import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses, ThemeType } from '../theme/themes';

const SettingsScreen = () => {
    const { theme, setTheme } = useAppTheme();
    const themeClasses = getThemeClasses(theme);

    const themes: { id: ThemeType; label: string; icon: string; color: string }[] = [
        { id: 'light', label: 'Light (Green)', icon: 'white-balance-sunny', color: '#10b981' },
        { id: 'dark', label: 'Dark', icon: 'moon-waning-crescent', color: '#10b981' },
        { id: 'dark-pink', label: 'Dark Pink', icon: 'heart', color: '#ec4899' },
    ];

    return (
        <View className={`flex-1 ${themeClasses.bg.background}`}>
            <ScrollView className="p-4">
                <Text className={`text-2xl font-bold mb-4 ${themeClasses.text.primary}`}>
                    Settings
                </Text>

                <Text className={`text-lg font-semibold mb-3 ${themeClasses.text.primary}`}>
                    Theme
                </Text>

                {themes.map(t => (
                    <TouchableOpacity
                        key={t.id}
                        onPress={() => setTheme(t.id)}
                        className={`flex-row items-center justify-between p-4 rounded-lg mb-2 border ${theme === t.id ? 'border-2' : themeClasses.border
                            } ${themeClasses.bg.surface}`}
                        style={theme === t.id ? { borderColor: t.color } : {}}
                    >
                        <View className="flex-row items-center">
                            <View
                                className="w-12 h-12 rounded-full items-center justify-center mr-3"
                                style={{ backgroundColor: t.color }}
                            >
                                <MaterialCommunityIcons name={t.icon as any} size={24} color="white" />
                            </View>
                            <Text className={`text-base font-semibold ${themeClasses.text.primary}`}>
                                {t.label}
                            </Text>
                        </View>
                        {theme === t.id && (
                            <MaterialCommunityIcons name="check-circle" size={24} color={t.color} />
                        )}
                    </TouchableOpacity>
                ))}

                <View className="mt-8">
                    <Text className={`text-sm ${themeClasses.text.secondary} text-center`}>
                        Budget Buddy v1.0.0
                    </Text>
                    <Text className={`text-sm ${themeClasses.text.secondary} text-center mt-1`}>
                        Built with NativeWind & Expo
                    </Text>
                </View>
            </ScrollView>
        </View>
    );
};

export default SettingsScreen;
