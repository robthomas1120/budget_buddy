import React, { useState } from 'react';
import { View, StyleSheet, Modal, TouchableOpacity, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { Text, Button, TextInput, useTheme, Card, RadioButton } from 'react-native-paper';
import { Account } from '../types';

interface DepositModalProps {
    visible: boolean;
    onClose: () => void;
    onDeposit: (amount: number, accountId: number) => void;
    accounts: Account[];
    goalName: string;
}

const DepositModal: React.FC<DepositModalProps> = ({ visible, onClose, onDeposit, accounts, goalName }) => {
    const theme = useTheme();
    const [amount, setAmount] = useState('');
    const [selectedAccountId, setSelectedAccountId] = useState<number | undefined>(accounts.length > 0 ? accounts[0].id : undefined);

    const handleDeposit = () => {
        const parsedAmount = parseFloat(amount);
        if (isNaN(parsedAmount) || parsedAmount <= 0) {
            return; // Add validation error handling if needed
        }
        if (selectedAccountId) {
            onDeposit(parsedAmount, selectedAccountId);
            setAmount('');
            onClose();
        }
    };

    return (
        <Modal
            visible={visible}
            transparent
            animationType="slide"
            onRequestClose={onClose}
        >
            <KeyboardAvoidingView
                behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
                style={styles.modalOverlay}
            >
                <View style={[styles.modalContent, { backgroundColor: theme.colors.surface }]}>
                    <Text style={[styles.title, { color: theme.colors.primary }]}>Deposit to {goalName}</Text>

                    <TextInput
                        label="Amount"
                        value={amount}
                        onChangeText={setAmount}
                        keyboardType="numeric"
                        left={<TextInput.Affix text="₱ " />}
                        style={styles.input}
                        mode="outlined"
                        autoFocus
                    />

                    <Text style={styles.label}>Debit From Account</Text>
                    <ScrollView style={styles.accountList}>
                        {accounts.map(acc => (
                            <TouchableOpacity
                                key={acc.id}
                                style={[
                                    styles.accountItem,
                                    selectedAccountId === acc.id && { backgroundColor: theme.colors.primaryContainer }
                                ]}
                                onPress={() => setSelectedAccountId(acc.id)}
                            >
                                <View style={styles.accountInfo}>
                                    <Text style={styles.accountName}>{acc.name}</Text>
                                    <Text style={styles.accountBalance}>₱{acc.balance.toFixed(2)}</Text>
                                </View>
                                <RadioButton
                                    value={acc.id!.toString()}
                                    status={selectedAccountId === acc.id ? 'checked' : 'unchecked'}
                                    onPress={() => setSelectedAccountId(acc.id)}
                                />
                            </TouchableOpacity>
                        ))}
                    </ScrollView>

                    <View style={styles.actions}>
                        <Button mode="text" onPress={onClose} style={styles.button}>Cancel</Button>
                        <Button mode="contained" onPress={handleDeposit} style={styles.button} disabled={!amount || !selectedAccountId}>
                            Deposit
                        </Button>
                    </View>
                </View>
            </KeyboardAvoidingView>
        </Modal>
    );
};

const styles = StyleSheet.create({
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'flex-end',
    },
    modalContent: {
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        padding: 20,
        maxHeight: '80%',
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
        marginBottom: 20,
        textAlign: 'center',
    },
    input: {
        marginBottom: 20,
    },
    label: {
        fontSize: 16,
        fontWeight: 'bold',
        marginBottom: 10,
    },
    accountList: {
        maxHeight: 200,
        marginBottom: 20,
    },
    accountItem: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: 12,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#eee',
        marginBottom: 8,
    },
    accountInfo: {
        flex: 1,
    },
    accountName: {
        fontSize: 16,
        fontWeight: 'bold',
    },
    accountBalance: {
        fontSize: 14,
        color: '#666',
    },
    actions: {
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
    button: {
        flex: 1,
        marginHorizontal: 5,
    }
});

export default DepositModal;
