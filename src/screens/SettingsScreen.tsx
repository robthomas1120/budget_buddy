import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { List, RadioButton, useTheme, Divider } from 'react-native-paper';
import { useAppTheme } from '../context/ThemeContext';

const SettingsScreen = () => {
    const { themeType, setThemeType } = useAppTheme();
    const theme = useTheme();

    return (
        <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
            <ScrollView contentContainerStyle={styles.content}>
                <List.Section title="Appearance">
                    <List.Accordion
                        title="Theme"
                        left={props => <List.Icon {...props} icon="theme-light-dark" />}
                        expanded={true}
                    >
                        <List.Item
                            title="Light"
                            left={() => <RadioButton value="light" status={themeType === 'light' ? 'checked' : 'unchecked'} onPress={() => setThemeType('light')} />}
                            onPress={() => setThemeType('light')}
                        />
                        <Divider />
                        <List.Item
                            title="Dark"
                            left={() => <RadioButton value="dark" status={themeType === 'dark' ? 'checked' : 'unchecked'} onPress={() => setThemeType('dark')} />}
                            onPress={() => setThemeType('dark')}
                        />
                        <Divider />
                        <List.Item
                            title="Dark Pink"
                            left={() => <RadioButton value="dark-pink" status={themeType === 'dark-pink' ? 'checked' : 'unchecked'} onPress={() => setThemeType('dark-pink')} />}
                            onPress={() => setThemeType('dark-pink')}
                        />
                    </List.Accordion>
                </List.Section>

                <List.Section title="About">
                    <List.Item title="Version" description="1.0.0" left={props => <List.Icon {...props} icon="information" />} />
                </List.Section>

            </ScrollView>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    content: {
        padding: 16,
    },
});

export default SettingsScreen;
