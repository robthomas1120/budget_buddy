import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses, ThemeType } from '../theme/themes';

import { useCurrency, AVAILABLE_CURRENCIES } from '../context/CurrencyContext';

const SettingsScreen = () => {
    const { theme, setTheme } = useAppTheme();
    const { currency, setCurrency } = useCurrency();
    const [isCurrencyExpanded, setIsCurrencyExpanded] = React.useState(false);
    const themeClasses = getThemeClasses(theme);

    const themes: { id: ThemeType; label: string; icon: string; color: string }[] = [
        { id: 'light', label: 'Light (Green)', icon: 'white-balance-sunny', color: '#10b981' },
        { id: 'dark', label: 'Dark', icon: 'moon-waning-crescent', color: '#10b981' },
        { id: 'dark-pink', label: 'Dark Pink', icon: 'heart', color: '#ec4899' },
    ];

    const themePrimaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

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

                <Text className={`text-lg font-semibold mt-6 mb-3 ${themeClasses.text.primary}`}>
                    Currency
                </Text>

                <View className="mb-6">
                    <TouchableOpacity
                        onPress={() => setIsCurrencyExpanded(!isCurrencyExpanded)}
                        className={`flex-row items-center justify-between p-4 rounded-lg border ${themeClasses.border} ${themeClasses.bg.surface}`}
                    >
                        <View className="flex-row items-center">
                            <View
                                className="w-10 h-10 rounded-full items-center justify-center mr-3 bg-gray-200"
                                style={{ backgroundColor: themePrimaryColor }}
                            >
                                <Text className="text-white text-lg font-bold">{currency.symbol}</Text>
                            </View>
                            <Text className={`text-base font-semibold ${themeClasses.text.primary}`}>
                                {currency.name} ({currency.code})
                            </Text>
                        </View>
                        <MaterialCommunityIcons
                            name={isCurrencyExpanded ? "chevron-up" : "chevron-down"}
                            size={24}
                            color={theme === 'light' ? '#4B5563' : '#9CA3AF'}
                        />
                    </TouchableOpacity>

                    {isCurrencyExpanded && (
                        <View className="mt-2 pl-4 border-l-2 border-gray-200 dark:border-gray-700 ml-5">
                            {AVAILABLE_CURRENCIES.filter(c => c.code !== currency.code).map(c => (
                                <TouchableOpacity
                                    key={c.code}
                                    onPress={() => {
                                        setCurrency(c);
                                        setIsCurrencyExpanded(false);
                                    }}
                                    className={`flex-row items-center justify-between p-3 rounded-lg mb-2 ${themeClasses.bg.surface}`}
                                >
                                    <View className="flex-row items-center">
                                        <View className="w-8 mr-3 items-center">
                                            <Text className={`text-lg font-bold ${themeClasses.text.primary}`}>{c.symbol}</Text>
                                        </View>
                                        <Text className={`text-base ${themeClasses.text.primary}`}>
                                            {c.name} ({c.code})
                                        </Text>
                                    </View>
                                </TouchableOpacity>
                            ))}
                        </View>
                    )}
                </View>

                <View className="mt-8 mb-8">
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
