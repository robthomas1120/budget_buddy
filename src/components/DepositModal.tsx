import React, { useState } from 'react';
import { View, Modal, TouchableOpacity, ScrollView, KeyboardAvoidingView, Platform, TextInput } from 'react-native';
import { Text } from 'react-native';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Account } from '../types';
import { useAppTheme } from '../context/ThemeContext';
import { getThemeClasses } from '../theme/themes';
import { useCurrency } from '../context/CurrencyContext';

interface DepositModalProps {
    visible: boolean;
    onClose: () => void;
    onDeposit: (amount: number, accountId: number) => void;
    accounts: Account[];
    goalName: string;
}

const DepositModal: React.FC<DepositModalProps> = ({ visible, onClose, onDeposit, accounts, goalName }) => {
    const { theme } = useAppTheme();
    const { currency } = useCurrency();
    const themeClasses = getThemeClasses(theme);
    const [amount, setAmount] = useState('');
    const [selectedAccountId, setSelectedAccountId] = useState<number | undefined>(accounts.length > 0 ? accounts[0].id : undefined);

    const handleDeposit = () => {
        const parsedAmount = parseFloat(amount);
        if (isNaN(parsedAmount) || parsedAmount <= 0) {
            return;
        }
        if (selectedAccountId) {
            onDeposit(parsedAmount, selectedAccountId);
            setAmount('');
            onClose();
        }
    };

    const primaryColor = theme === 'light' ? '#10b981' : theme === 'dark' ? '#10b981' : '#ec4899';

    return (
        <Modal
            visible={visible}
            transparent
            animationType="slide"
            onRequestClose={onClose}
        >
            <KeyboardAvoidingView
                behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
                className="flex-1 bg-black/50 justify-end"
            >
                <View className={`rounded-t-3xl p-5 ${themeClasses.bg.surface}`}>
                    <Text className={`text-xl font-bold mb-5 text-center ${themeClasses.text.primary}`}>
                        Deposit to {goalName}
                    </Text>

                    <View className={`border rounded-lg px-3 py-2 mb-5 ${themeClasses.border} ${themeClasses.bg.background}`}>
                        <Text className={`text-xs ${themeClasses.text.secondary} mb-1`}>Amount</Text>
                        <View className="flex-row items-center">
                            <Text className={`text-base ${themeClasses.text.primary} mr-2`}>{currency.symbol}</Text>
                            <TextInput
                                value={amount}
                                onChangeText={setAmount}
                                keyboardType="numeric"
                                placeholder="0.00"
                                placeholderTextColor={theme === 'light' ? '#9CA3AF' : '#6B7280'}
                                className={`flex-1 text-base ${themeClasses.text.primary}`}
                                autoFocus
                            />
                        </View>
                    </View>

                    <Text className={`text-base font-bold mb-2.5 ${themeClasses.text.primary}`}>
                        Debit From Account
                    </Text>
                    <ScrollView className="max-h-48 mb-5">
                        {accounts.map(acc => (
                            <TouchableOpacity
                                key={acc.id}
                                className={`flex-row items-center justify-between p-3 rounded-lg border mb-2 ${selectedAccountId === acc.id ? 'bg-green-50 border-green-500' : `${themeClasses.border} ${themeClasses.bg.background}`
                                    }`}
                                onPress={() => setSelectedAccountId(acc.id)}
                                style={selectedAccountId === acc.id && theme !== 'light' ? {
                                    backgroundColor: theme === 'dark' ? '#1f2937' : '#27272a',
                                    borderColor: primaryColor
                                } : {}}
                            >
                                <View className="flex-1">
                                    <Text className={`text-base font-bold ${themeClasses.text.primary}`}>
                                        {acc.name}
                                    </Text>
                                    <Text className={`text-sm ${themeClasses.text.secondary}`}>
                                        {currency.symbol}{acc.balance.toFixed(2)}
                                    </Text>
                                </View>
                                <View
                                    className={`w-5 h-5 rounded-full border-2 items-center justify-center ${selectedAccountId === acc.id ? 'border-green-500' : themeClasses.border
                                        }`}
                                    style={selectedAccountId === acc.id ? { borderColor: primaryColor } : {}}
                                >
                                    {selectedAccountId === acc.id && (
                                        <View className="w-3 h-3 rounded-full bg-green-500" style={{ backgroundColor: primaryColor }} />
                                    )}
                                </View>
                            </TouchableOpacity>
                        ))}
                    </ScrollView>

                    <View className="flex-row">
                        <TouchableOpacity
                            onPress={onClose}
                            className={`flex-1 py-3 rounded-lg mr-2 border ${themeClasses.border} ${themeClasses.bg.surfaceVariant}`}
                        >
                            <Text className={`text-center font-semibold ${themeClasses.text.primary}`}>
                                Cancel
                            </Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            onPress={handleDeposit}
                            disabled={!amount || !selectedAccountId}
                            className={`flex-1 py-3 rounded-lg ml-2 ${!amount || !selectedAccountId ? 'opacity-50' : ''}`}
                            style={{ backgroundColor: primaryColor }}
                        >
                            <Text className="text-center font-semibold text-white">
                                Deposit
                            </Text>
                        </TouchableOpacity>
                    </View>
                </View>
            </KeyboardAvoidingView>
        </Modal>
    );
};

export default DepositModal;
