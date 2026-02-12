import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

export type CurrencyType = {
    code: string;
    symbol: string;
    name: string;
};

export const AVAILABLE_CURRENCIES: CurrencyType[] = [
    { code: 'PHP', symbol: '₱', name: 'Philippine Peso' },
    { code: 'USD', symbol: '$', name: 'US Dollar' },
    { code: 'EUR', symbol: '€', name: 'Euro' },
    { code: 'GBP', symbol: '£', name: 'British Pound' },
    { code: 'INR', symbol: '₹', name: 'Indian Rupee' },
    { code: 'JPY', symbol: '¥', name: 'Japanese Yen' },
    { code: 'KRW', symbol: '₩', name: 'South Korean Won' },
    { code: 'AUD', symbol: 'A$', name: 'Australian Dollar' },
    { code: 'CAD', symbol: 'C$', name: 'Canadian Dollar' },
    { code: 'CNY', symbol: '¥', name: 'Chinese Yuan' },
];

interface CurrencyContextType {
    currency: CurrencyType;
    setCurrency: (currency: CurrencyType) => void;
}

const CurrencyContext = createContext<CurrencyContextType | undefined>(undefined);

const CURRENCY_STORAGE_KEY = '@budget_buddy_currency';

export const CurrencyProvider = ({ children }: { children: ReactNode }) => {
    const [currency, setCurrencyState] = useState<CurrencyType>(AVAILABLE_CURRENCIES[0]); // Default to PHP

    useEffect(() => {
        loadCurrency();
    }, []);

    const loadCurrency = async () => {
        try {
            const savedCurrencyCode = await AsyncStorage.getItem(CURRENCY_STORAGE_KEY);
            if (savedCurrencyCode) {
                const foundCurrency = AVAILABLE_CURRENCIES.find(c => c.code === savedCurrencyCode);
                if (foundCurrency) {
                    setCurrencyState(foundCurrency);
                }
            }
        } catch (error) {
            console.error('Failed to load currency', error);
        }
    };

    const setCurrency = async (newCurrency: CurrencyType) => {
        try {
            setCurrencyState(newCurrency);
            await AsyncStorage.setItem(CURRENCY_STORAGE_KEY, newCurrency.code);
        } catch (error) {
            console.error('Failed to save currency', error);
        }
    };

    return (
        <CurrencyContext.Provider value={{ currency, setCurrency }}>
            {children}
        </CurrencyContext.Provider>
    );
};

export const useCurrency = () => {
    const context = useContext(CurrencyContext);
    if (!context) {
        throw new Error('useCurrency must be used within CurrencyProvider');
    }
    return context;
};
