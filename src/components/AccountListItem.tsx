import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Surface, useTheme } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Account } from '../types';

interface AccountListItemProps {
    account: Account;
    onPress: () => void;
}

const AccountListItem: React.FC<AccountListItemProps> = ({ account, onPress }) => {
    const theme = useTheme();

    let iconName: keyof typeof MaterialCommunityIcons.glyphMap = 'credit-card';
    let iconColor = theme.colors.primary;

    switch (account.type.toLowerCase()) {
        case 'bank':
            iconName = 'bank';
            iconColor = '#2196F3'; // Blue
            break;
        case 'e-wallet':
        case 'ewallet':
            iconName = 'cellphone';
            iconColor = '#9C27B0'; // Purple
            break;
        case 'cash':
            iconName = 'cash';
            iconColor = '#4CAF50'; // Green
            break;
        default:
            iconName = 'credit-card';
            iconColor = '#607D8B'; // Grey
    }

    return (
        <Surface style={styles.container} elevation={1}>
            <TouchableOpacity style={styles.content} onPress={onPress}>
                <View style={[styles.iconContainer, { backgroundColor: `${iconColor}20` }]}>
                    <MaterialCommunityIcons name={iconName} size={24} color={iconColor} />
                </View>

                <View style={styles.details}>
                    <Text style={styles.name}>{account.name}</Text>
                    <Text style={styles.type}>{account.type}</Text>
                </View>

                <Text style={styles.balance}>₱{account.balance.toFixed(2)}</Text>
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
        borderRadius: 22,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 16,
    },
    details: {
        flex: 1,
    },
    name: {
        fontSize: 16,
        fontWeight: 'bold',
    },
    type: {
        fontSize: 14,
        color: '#666',
        marginTop: 2,
        textTransform: 'capitalize',
    },
    balance: {
        fontSize: 16,
        fontWeight: 'bold',
    },
});

export default AccountListItem;
