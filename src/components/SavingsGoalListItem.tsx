import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Surface, useTheme, ProgressBar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { SavingsGoal } from '../types';

interface SavingsGoalListItemProps {
    goal: SavingsGoal;
    onPress: () => void;
    onDeposit: () => void;
}

const SavingsGoalListItem: React.FC<SavingsGoalListItemProps> = ({ goal, onPress, onDeposit }) => {
    const theme = useTheme();

    const progress = Math.min(Math.max(goal.currentAmount / goal.targetAmount, 0), 1);
    const remaining = goal.targetAmount - goal.currentAmount;
    const isCompleted = goal.currentAmount >= goal.targetAmount;

    return (
        <Surface style={styles.container} elevation={1}>
            <TouchableOpacity style={styles.content} onPress={onPress}>
                <View style={styles.header}>
                    <Text style={styles.name}>{goal.name}</Text>
                    {isCompleted && (
                        <View style={[styles.badge, { backgroundColor: '#4CAF50' }]}>
                            <Text style={styles.badgeText}>Completed</Text>
                        </View>
                    )}
                </View>

                <View style={styles.progressContainer}>
                    <ProgressBar
                        progress={progress}
                        color={isCompleted ? '#4CAF50' : theme.colors.primary}
                        style={styles.progressBar}
                    />
                </View>

                <View style={styles.footer}>
                    <View>
                        <Text style={styles.amountText}>
                            <Text style={{ fontWeight: 'bold', color: theme.colors.primary }}>₱{goal.currentAmount.toFixed(2)}</Text>
                            <Text style={{ color: '#666' }}> / ₱{goal.targetAmount.toFixed(2)}</Text>
                        </Text>
                        {!isCompleted && (
                            <Text style={styles.remainingText}>₱{remaining.toFixed(2)} to go</Text>
                        )}
                    </View>

                    <TouchableOpacity
                        style={[styles.depositButton, { backgroundColor: theme.colors.primaryContainer }]}
                        onPress={onDeposit}
                    >
                        <MaterialCommunityIcons name="plus" size={20} color={theme.colors.primary} />
                        <Text style={[styles.depositText, { color: theme.colors.primary }]}>Deposit</Text>
                    </TouchableOpacity>
                </View>
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
        alignItems: 'center',
        marginBottom: 12,
    },
    name: {
        fontSize: 18,
        fontWeight: 'bold',
    },
    badge: {
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 10,
    },
    badgeText: {
        color: 'white',
        fontSize: 12,
        fontWeight: 'bold',
    },
    progressContainer: {
        height: 10,
        borderRadius: 5,
        overflow: 'hidden',
        backgroundColor: '#f5f5f5',
        marginBottom: 12,
    },
    progressBar: {
        height: 10,
        borderRadius: 5,
    },
    footer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    amountText: {
        fontSize: 16,
    },
    remainingText: {
        fontSize: 12,
        color: '#888',
        marginTop: 2,
    },
    depositButton: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 20,
    },
    depositText: {
        fontSize: 14,
        fontWeight: 'bold',
        marginLeft: 4,
    },
});

export default SavingsGoalListItem;
