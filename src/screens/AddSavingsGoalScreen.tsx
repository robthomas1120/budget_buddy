import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert } from 'react-native';
import { useTheme, Button, TextInput, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useApp } from '../context/AppContext';
import { insertSavingsGoal } from '../database/SavingsHelper';
import { SavingsGoal } from '../types';

const AddSavingsGoalScreen = () => {
    const navigation = useNavigation();
    const theme = useTheme();
    const { db, refreshData } = useApp();

    const [name, setName] = useState('');
    const [targetAmount, setTargetAmount] = useState('');
    const [initialAmount, setInitialAmount] = useState('');
    const [targetDate, setTargetDate] = useState<Date | undefined>(undefined); // Not implemented in MVP UI yet but in model

    const handleSave = async () => {
        if (!name || !targetAmount) {
            Alert.alert('Error', 'Please fill in all required fields');
            return;
        }

        const parsedTarget = parseFloat(targetAmount);
        const parsedInitial = initialAmount ? parseFloat(initialAmount) : 0;

        if (isNaN(parsedTarget) || parsedTarget <= 0) {
            Alert.alert('Error', 'Invalid target amount');
            return;
        }

        try {
            if (db) {
                const newGoal: SavingsGoal = {
                    name,
                    targetAmount: parsedTarget,
                    currentAmount: parsedInitial,
                    startDate: Date.now(),
                    targetDate: Date.now(), // Default to now for MVP
                    isActive: true,
                    icon: 'piggy-bank', // Default
                    color: 'green' // Default
                };

                await insertSavingsGoal(db, newGoal);
                await refreshData();
                navigation.goBack();
            }
        } catch (error) {
            console.error(error);
            Alert.alert('Error', 'Failed to save savings goal');
        }
    };

    return (
        <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
            <View style={styles.header}>
                <IconButton icon="close" onPress={() => navigation.goBack()} />
                <Text style={styles.headerTitle}>New Savings Goal</Text>
                <Button mode="text" onPress={handleSave}>Save</Button>
            </View>

            <ScrollView contentContainerStyle={styles.content}>
                <TextInput
                    label="Goal Name"
                    value={name}
                    onChangeText={setName}
                    placeholder="e.g. New Car, Vacation"
                    style={styles.input}
                    mode="outlined"
                />

                <TextInput
                    label="Target Amount"
                    value={targetAmount}
                    onChangeText={setTargetAmount}
                    keyboardType="numeric"
                    left={<TextInput.Affix text="₱ " />}
                    style={styles.input}
                    mode="outlined"
                />

                <TextInput
                    label="Initial Amount (Optional)"
                    value={initialAmount}
                    onChangeText={setInitialAmount}
                    keyboardType="numeric"
                    left={<TextInput.Affix text="₱ " />}
                    style={styles.input}
                    mode="outlined"
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
});

export default AddSavingsGoalScreen;
