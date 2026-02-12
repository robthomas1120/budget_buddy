import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Surface, useTheme } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';

interface BalanceSummaryCardProps {
    currentBalance: number;
    onBalanceTap: () => void;
}

const BalanceSummaryCard: React.FC<BalanceSummaryCardProps> = ({ currentBalance, onBalanceTap }) => {
    const [isBalanceVisible, setIsBalanceVisible] = useState(false);
    const theme = useTheme();

    return (
        <Surface style={[styles.container, { backgroundColor: theme.colors.primary }]} elevation={4}>
            <View style={styles.contentRow}>
                <TouchableOpacity onPress={onBalanceTap} activeOpacity={0.9} style={styles.textContainer}>
                    <Text style={styles.label}>Current Balance</Text>
                    <Text style={styles.balanceText}>
                        {isBalanceVisible ? `₱${currentBalance.toFixed(2)}` : '₱ ******'}
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    onPress={() => setIsBalanceVisible(!isBalanceVisible)}
                    hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                    style={styles.iconContainer}
                >
                    <MaterialCommunityIcons
                        name={isBalanceVisible ? "eye-off" : "eye"}
                        size={28}
                        color="white"
                    />
                </TouchableOpacity>
            </View>
        </Surface>
    );
};

const styles = StyleSheet.create({
    container: {
        padding: 20,
        borderRadius: 12,
        marginVertical: 10,
    },
    contentRow: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    textContainer: {
        flex: 1,
        justifyContent: 'center',
    },
    label: {
        color: 'white',
        fontSize: 16,
        marginBottom: 4,
        fontFamily: 'System',
    },
    balanceText: {
        color: 'white',
        fontSize: 28,
        fontWeight: 'bold',
    },
    iconContainer: {
        paddingLeft: 10,
        justifyContent: 'center',
    }
});

export default BalanceSummaryCard;
