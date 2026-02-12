import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert } from 'react-native';
import { useTheme, Button, TextInput, SegmentedButtons, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../context/AppContext';
import { insertAccount } from '../database/AccountHelper';
import { Account } from '../types';

const AddAccountScreen = () => {
    const navigation = useNavigation();
    const theme = useTheme();
    const { db, refreshData } = useApp();

    const [name, setName] = useState('');
    const [balance, setBalance] = useState('');
    const [type, setType] = useState('cash');

    const handleSave = async () => {
        if (!name || !balance) {
            Alert.alert('Error', 'Please fill in all required fields');
            return;
        }

        const parsedBalance = parseFloat(balance);
        if (isNaN(parsedBalance)) {
            Alert.alert('Error', 'Invalid balance');
            return;
        }

        try {
            if (db) {
                const newAccount: Account = {
                    name,
                    type,
                    balance: parsedBalance,
                    iconName: 'default', // Placeholder, logical mapping done in UI based on type
                    color: 'default' // Placeholder
                };

                await insertAccount(db, newAccount);
                await refreshData();
                navigation.goBack();
            }
        } catch (error) {
            console.error(error);
            Alert.alert('Error', 'Failed to save account');
        }
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
            <View style={styles.header}>
                <IconButton icon="close" onPress={() => navigation.goBack()} />
                <Text style={styles.headerTitle}>Add Account</Text>
                <Button mode="text" onPress={handleSave}>Save</Button>
            </View>

            <ScrollView contentContainerStyle={styles.content}>
                <TextInput
                    label="Account Name"
                    value={name}
                    onChangeText={setName}
                    style={styles.input}
                    mode="outlined"
                />

                <TextInput
                    label="Current Balance"
                    value={balance}
                    onChangeText={setBalance}
                    keyboardType="numeric"
                    left={<TextInput.Affix text="₱ " />}
                    style={styles.input}
                    mode="outlined"
                />

                <Text style={styles.label}>Account Type</Text>
                <SegmentedButtons
                    value={type}
                    onValueChange={setType}
                    buttons={[
                        { value: 'cash', label: 'Cash' },
                        { value: 'bank', label: 'Bank' },
                        { value: 'e-wallet', label: 'E-Wallet' },
                    ]}
                    style={styles.segment}
                />
            </ScrollView>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 8,
        paddingVertical: 8,
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: 'bold',
    },
    content: {
        padding: 16,
    },
    input: {
        marginBottom: 16,
    },
    label: {
        fontSize: 16,
        fontWeight: 'bold',
        marginBottom: 8,
        marginTop: 8,
    },
    segment: {
        marginBottom: 16,
    },
});

export default AddAccountScreen;
