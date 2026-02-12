import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert, TouchableOpacity, Platform } from 'react-native';
import { useTheme, Button, TextInput, SegmentedButtons, IconButton } from 'react-native-paper';
import { useNavigation, useRoute } from '@react-navigation/native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useApp } from '../context/AppContext';
import { insertTransaction, updateTransaction } from '../database/TransactionHelper';
import { Transaction } from '../types';

const AddTransactionScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const theme = useTheme();
  const { accounts, budgets, db, refreshData } = useApp();

  // Params for editing
  const { transaction } = (route.params as { transaction?: Transaction }) || {};
  const isEditing = !!transaction;

  const [title, setTitle] = useState(transaction?.title || '');
  const [amount, setAmount] = useState(transaction?.amount.toString() || '');
  const [type, setType] = useState<'income' | 'expense'>(transaction?.type || 'expense');
  const [category, setCategory] = useState(transaction?.category || 'Food');
  const [date, setDate] = useState(transaction ? new Date(transaction.date) : new Date());
  const [notes, setNotes] = useState(transaction?.notes || '');
  const [accountId, setAccountId] = useState<number | undefined>(transaction?.accountId || (accounts.length > 0 ? accounts[0].id : undefined));
  const [budgetId, setBudgetId] = useState<number | undefined>(transaction?.budgetId);

  const [showDatePicker, setShowDatePicker] = useState(false);

  const incomeCategories = ['Salary', 'Freelance', 'Investments', 'Gift', 'Other'];
  const expenseCategories = ['Food', 'Transportation', 'Entertainment', 'Housing', 'Shopping', 'Utilities', 'Healthcare', 'Education', 'Other'];

  useEffect(() => {
    // Reset category if type changes and current category isn't valid for new type
    if (type === 'income' && !incomeCategories.includes(category)) {
      setCategory(incomeCategories[0]);
    } else if (type === 'expense' && !expenseCategories.includes(category)) {
      setCategory(expenseCategories[0]);
    }
  }, [type]);

  const handleSave = async () => {
    if (!title || !amount || !accountId) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount)) {
      Alert.alert('Error', 'Invalid amount');
      return;
    }

    try {
      if (db) {
        const transactionData: Transaction = {
          id: transaction?.id,
          title,
          amount: parsedAmount,
          type,
          category,
          date: date.getTime(),
          notes,
          accountId,
          budgetId
        };

        if (isEditing) {
          await updateTransaction(db, transactionData);
        } else {
          await insertTransaction(db, transactionData);
        }

        await refreshData();
        navigation.goBack();
      }
    } catch (error) {
      console.error(error);
      Alert.alert('Error', 'Failed to save transaction');
    }
  };

  const onDateChange = (event: any, selectedDate?: Date) => {
    setShowDatePicker(Platform.OS === 'ios');
    if (selectedDate) {
      setDate(selectedDate);
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <View style={styles.header}>
        <IconButton icon="close" onPress={() => navigation.goBack()} />
        <Text style={styles.headerTitle}>{isEditing ? 'Edit Transaction' : 'Add Transaction'}</Text>
        <Button mode="text" onPress={handleSave}>Save</Button>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <SegmentedButtons
          value={type}
          onValueChange={value => setType(value as 'income' | 'expense')}
          buttons={[
            { value: 'income', label: 'Income', style: { backgroundColor: type === 'income' ? theme.colors.primaryContainer : undefined } },
            { value: 'expense', label: 'Expense', style: { backgroundColor: type === 'expense' ? theme.colors.errorContainer : undefined } },
          ]}
          style={styles.segment}
        />

        <TextInput
          label="Amount"
          value={amount}
          onChangeText={setAmount}
          keyboardType="numeric"
          left={<TextInput.Affix text="₱ " />}
          style={styles.input}
          mode="outlined"
        />

        <TextInput
          label="Title"
          value={title}
          onChangeText={setTitle}
          style={styles.input}
          mode="outlined"
        />

        <Text style={styles.label}>Budget (Optional)</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.chipContainer}>
          <TouchableOpacity
            style={[
              styles.chip,
              styles.budgetChip,
              !budgetId && { backgroundColor: theme.colors.secondaryContainer }
            ]}
            onPress={() => setBudgetId(undefined)}
          >
            <Text style={[styles.chipText, !budgetId && { fontWeight: 'bold' }]}>None</Text>
          </TouchableOpacity>
          {budgets.filter(b => b.isActive).map(budget => (
            <TouchableOpacity
              key={budget.id}
              style={[
                styles.chip,
                styles.budgetChip,
                budgetId === budget.id && { backgroundColor: theme.colors.secondary }
              ]}
              onPress={() => setBudgetId(budget.id)}
            >
              <Text style={[styles.chipText, budgetId === budget.id && { color: theme.colors.onSecondary }]}>{budget.title}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <Text style={styles.label}>Category</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.chipContainer}>
          {(type === 'income' ? incomeCategories : expenseCategories).map(cat => (
            <TouchableOpacity
              key={cat}
              style={[
                styles.chip,
                category === cat && { backgroundColor: theme.colors.primary }
              ]}
              onPress={() => setCategory(cat)}
            >
              <Text style={[styles.chipText, category === cat && { color: 'white' }]}>{cat}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <Text style={styles.label}>Account</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.chipContainer}>
          {accounts.map(acc => (
            <TouchableOpacity
              key={acc.id}
              style={[
                styles.chip,
                accountId === acc.id && { backgroundColor: theme.colors.primary }
              ]}
              onPress={() => setAccountId(acc.id)}
            >
              <Text style={[styles.chipText, accountId === acc.id && { color: 'white' }]}>{acc.name}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        <TouchableOpacity onPress={() => setShowDatePicker(true)}>
          <TextInput
            label="Date"
            value={date.toLocaleDateString()}
            editable={false}
            right={<TextInput.Icon icon="calendar" onPress={() => setShowDatePicker(true)} />}
            style={styles.input}
            mode="outlined"
          />
        </TouchableOpacity>

        {showDatePicker && (
          <DateTimePicker
            value={date}
            mode="date"
            display="default"
            onChange={onDateChange}
          />
        )}

        <TextInput
          label="Notes"
          value={notes}
          onChangeText={setNotes}
          multiline
          numberOfLines={3}
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
  segment: {
    marginBottom: 16,
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
  chipContainer: {
    flexDirection: 'row',
    marginBottom: 16,
  },
  chip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#e0e0e0',
    marginRight: 8,
  },
  chipText: {
    fontSize: 14,
  },
  budgetChip: {
    borderWidth: 1,
    borderColor: '#ccc',
    backgroundColor: 'transparent',
  },
});

export default AddTransactionScreen;
