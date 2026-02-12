import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Surface, useTheme } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Transaction } from '../types';

interface TransactionListItemProps {
    transaction: Transaction;
    onDelete: () => void;
    onUpdate: () => void;
}

const TransactionListItem: React.FC<TransactionListItemProps> = ({ transaction, onDelete, onUpdate }) => {
    const theme = useTheme();
    const isIncome = transaction.type === 'income';
    const transactionColor = isIncome ? '#4CAF50' : '#F44336'; // Green or Red

    const formattedDate = new Date(transaction.date).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
    });

    return (
        <Surface style={styles.container} elevation={1}>
            <TouchableOpacity
                style={styles.content}
                onPress={onUpdate}
                onLongPress={onDelete} // Simple way to trigger delete for now
            >
                <View style={[styles.iconContainer, { backgroundColor: `${transactionColor}20` }]}>
                    <MaterialCommunityIcons
                        name={isIncome ? "arrow-down" : "arrow-up"}
                        size={24}
                        color={transactionColor}
                    />
                </View>

                <View style={styles.detailsContainer}>
                    <Text style={[styles.title, { color: transactionColor }]}>{transaction.title}</Text>
                    <Text style={styles.subtitle}>
                        {transaction.category} • {formattedDate}
                    </Text>
                </View>

                <Text style={[styles.amount, { color: transactionColor }]}>
                    ₱{transaction.amount.toFixed(2)}
                </Text>
            </TouchableOpacity>
        </Surface>
    );
};

const styles = StyleSheet.create({
    container: {
        marginVertical: 6,
        borderRadius: 12,
        backgroundColor: 'white',
    },
    content: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 16,
    },
    iconContainer: {
        width: 44,
        height: 44,
        borderRadius: 10,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 12,
    },
    detailsContainer: {
        flex: 1,
    },
    title: {
        fontSize: 16,
        fontWeight: 'bold',
    },
    subtitle: {
        fontSize: 14,
        color: '#666',
        marginTop: 4,
    },
    amount: {
        fontSize: 16,
        fontWeight: 'bold',
    },
});

export default TransactionListItem;
