import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Surface, useTheme, ProgressBar } from 'react-native-paper';
import { Budget } from '../types';

interface BudgetListItemProps {
    budget: Budget;
    onPress: () => void;
}

const BudgetListItem: React.FC<BudgetListItemProps> = ({ budget, onPress }) => {
    const theme = useTheme();

    const progress = Math.min(Math.max(budget.spent / budget.amount, 0), 1);
    const isOverBudget = budget.spent > budget.amount;
    const remaining = budget.amount - budget.spent;

    let statusColor = theme.colors.primary;
    if (progress > 0.9) {
        statusColor = theme.colors.error;
    } else if (progress > 0.7) {
        statusColor = '#ff9800'; // Orange
    }

    const startDate = new Date(budget.startDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
    const endDate = new Date(budget.endDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });

    return (
        <Surface style={styles.container} elevation={1}>
            <TouchableOpacity style={styles.content} onPress={onPress}>
                <View style={styles.header}>
                    <View style={styles.titleContainer}>
                        <Text style={styles.title} numberOfLines={1}>{budget.title}</Text>
                        <Text style={styles.subtitle} numberOfLines={1}>{budget.category}</Text>
                    </View>
                    <View style={[styles.badge, { backgroundColor: '#e3f2fd' }]}>
                        {/* Simple active check logic for display */}
                        <Text style={[styles.badgeText, { color: theme.colors.primary }]}>Active</Text>
                    </View>
                </View>

                <Text style={styles.dates}>{startDate} - {endDate}</Text>

                <View style={styles.progressContainer}>
                    <ProgressBar progress={progress} color={statusColor} style={styles.progressBar} />
                </View>

                <View style={styles.footer}>
                    <Text style={styles.amountText}>₱{budget.spent.toFixed(2)} spent</Text>
                    <Text style={styles.amountText}>₱{budget.amount.toFixed(2)} budget</Text>
                </View>

                <Text style={[styles.statusText, { color: isOverBudget ? theme.colors.error : theme.colors.primary }]}>
                    {isOverBudget
                        ? `Over budget by ₱${Math.abs(remaining).toFixed(2)}`
                        : `₱${remaining.toFixed(2)} remaining`}
                </Text>
            </TouchableOpacity>
        </Surface>
    );
};

const styles = StyleSheet.create({
    container: {
        marginVertical: 8,
        borderRadius: 12,
        backgroundColor: 'white',
    },
    content: {
        padding: 16,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        marginBottom: 4,
    },
    titleContainer: {
        flex: 1,
        marginRight: 8,
    },
    title: {
        fontSize: 18,
        fontWeight: 'bold',
    },
    subtitle: {
        fontSize: 14,
        color: '#666',
    },
    badge: {
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 10,
    },
    badgeText: {
        fontSize: 12,
        fontWeight: 'bold',
    },
    dates: {
        fontSize: 12,
        color: '#888',
        marginBottom: 12,
    },
    progressContainer: {
        height: 10,
        borderRadius: 5,
        overflow: 'hidden',
        backgroundColor: '#f5f5f5',
        marginBottom: 8,
    },
    progressBar: {
        height: 10,
        borderRadius: 5,
    },
    footer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 4,
    },
    amountText: {
        fontSize: 14,
        color: '#444',
    },
    statusText: {
        fontSize: 14,
        fontWeight: 'bold',
    },
});

export default BudgetListItem;
