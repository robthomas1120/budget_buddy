import 'package:sqflite/sqflite.dart' as sqflite;
import '../../models/transaction.dart' as model;
import '../base_database_helper.dart';
import 'budget_helper.dart';
import 'account_helper.dart';
import 'savings_helper.dart';

class TransactionHelper {
  final BaseDatabaseHelper _baseHelper = BaseDatabaseHelper.instance;
  
  // Singleton pattern
  static final TransactionHelper instance = TransactionHelper._init();
  
  TransactionHelper._init();
  
  // Create transaction
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await _baseHelper.database;
    
    print('DEBUG: [TransactionHelper] Starting insertTransaction');
    print('DEBUG: [TransactionHelper] Transaction details:');
    print('DEBUG: [TransactionHelper] - Title: ${transaction.title}');
    print('DEBUG: [TransactionHelper] - Type: ${transaction.type}');
    print('DEBUG: [TransactionHelper] - Amount: ${transaction.amount}');
    print('DEBUG: [TransactionHelper] - Category: ${transaction.category}');
    print('DEBUG: [TransactionHelper] - Account ID: ${transaction.accountId}');
    print('DEBUG: [TransactionHelper] - Date: ${transaction.date}');
    
    // Start a transaction to ensure data consistency
    return await db.transaction((sqflite.Transaction txn) async {
      // Insert the transaction record
      final transactionId = await txn.insert('transactions', transaction.toMap());
      print('DEBUG: [TransactionHelper] Inserted transaction with ID: $transactionId');
      
      // If accountId is provided, update the account balance
      if (transaction.accountId != null) {
        // Get the current account balance
        final accountResult = await txn.query(
          'accounts',
          columns: ['balance'],
          where: 'id = ?',
          whereArgs: [transaction.accountId],
        );
        
        if (accountResult.isNotEmpty) {
          double currentBalance = accountResult.first['balance'] as double;
          double newBalance = currentBalance;
          
          // Add or subtract based on transaction type
          if (transaction.type == 'income') {
            newBalance += transaction.amount;
            print('DEBUG: [TransactionHelper] Updating account balance: $currentBalance + ${transaction.amount} = $newBalance');
          } else if (transaction.type == 'expense') {
            newBalance -= transaction.amount;
            print('DEBUG: [TransactionHelper] Updating account balance: $currentBalance - ${transaction.amount} = $newBalance');
            
            // For any expense transaction, update all budgets connected to this account
            await BudgetHelper.instance.adjustBudgetsForTransaction(
              txn,
              transaction.accountId,
              transaction.category,
              transaction.amount // Add the amount to the budget's spent
            );
          } else if (transaction.type == 'transfer') {
            // Handle transfer transactions
            newBalance -= transaction.amount;
            print('DEBUG: [TransactionHelper] Updating source account balance: $currentBalance - ${transaction.amount} = $newBalance');
          }
          
          // Update the account balance
          final updateResult = await txn.update(
            'accounts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [transaction.accountId],
          );
          
          print('DEBUG: [TransactionHelper] Account balance update result: $updateResult rows affected');
          
          // Verify the update was successful
          final updatedAccount = await txn.query(
            'accounts',
            columns: ['balance'],
            where: 'id = ?',
            whereArgs: [transaction.accountId],
          );
          
          if (updatedAccount.isNotEmpty) {
            double updatedBalance = updatedAccount.first['balance'] as double;
            print('DEBUG: [TransactionHelper] Verified new account balance: $updatedBalance');
          }
        } else {
          print('DEBUG: [TransactionHelper] Account with ID ${transaction.accountId} not found');
        }
      } else {
        print('DEBUG: [TransactionHelper] No account ID provided with transaction');
      }
      
      // Update savings goals within the same transaction
      await SavingsHelper.instance.updateSavingsGoalsFromAccounts(txn: txn);
      
      print('DEBUG: [TransactionHelper] Transaction processing complete, returning ID: $transactionId');
      return transactionId;
    });
  }
  
  // Read transactions
  Future<model.Transaction?> getTransaction(int id) async {
    final db = await _baseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return model.Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    final db = await _baseHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByType(String type) async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getRecentTransactions(int limit) async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByCategory(String category) async {
    final db = await _baseHelper.database;
    final result = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }
  
  // Get sum of amounts by type
  Future<double> getTotalIncome() async {
    return await _getSumByType('income');
  }

  Future<double> getTotalExpense() async {
    return await _getSumByType('expense');
  }

  Future<double> _getSumByType(String type) async {
    final db = await _baseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    
    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }
  
  // Update transaction
  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await _baseHelper.database;
    
    return await db.transaction((sqflite.Transaction txn) async {
      // First get the original transaction to calculate balance change
      final originalTransResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      if (originalTransResult.isEmpty) {
        return 0; // Transaction not found
      }
      
      final originalTrans = model.Transaction.fromMap(originalTransResult.first);
      
      // Update the transaction
      final updateResult = await txn.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      // If account ID has changed or amount has changed, update account balances
      if (transaction.accountId != null) {
        // If account has changed, handle both old and new accounts
        if (originalTrans.accountId != transaction.accountId && originalTrans.accountId != null) {
          // Adjust old account balance
          await AccountHelper.instance.adjustAccountBalance(
            txn,
            originalTrans.accountId!,
            originalTrans.type == 'income' ? -originalTrans.amount : originalTrans.amount,
          );
          
          // Adjust new account balance
          await AccountHelper.instance.adjustAccountBalance(
            txn,
            transaction.accountId!,
            transaction.type == 'income' ? transaction.amount : -transaction.amount,
          );
          
          // If this was an expense, update budgets for both old and new accounts
          if (originalTrans.type == 'expense') {
            // Remove the expense from the old account's budgets
            await BudgetHelper.instance.adjustBudgetsForTransaction(
              txn, 
              originalTrans.accountId, 
              originalTrans.category, 
              -originalTrans.amount
            );
          }
          
          if (transaction.type == 'expense') {
            // Add the expense to the new account's budgets
            await BudgetHelper.instance.adjustBudgetsForTransaction(
              txn, 
              transaction.accountId, 
              transaction.category, 
              transaction.amount
            );
          }
        } else {
          // Same account, just adjust the difference
          double balanceChange = 0.0;
          
          if (transaction.type == 'income') {
            balanceChange = transaction.amount - originalTrans.amount;
          } else {
            balanceChange = originalTrans.amount - transaction.amount;
          }
          
          await AccountHelper.instance.adjustAccountBalance(txn, transaction.accountId!, balanceChange);
          
          // Update budgets if this is an expense and amount has changed
          if (transaction.type == 'expense' && originalTrans.type == 'expense') {
            double amountDifference = transaction.amount - originalTrans.amount;
            
            if (amountDifference != 0) {
              await BudgetHelper.instance.adjustBudgetsForTransaction(
                txn, 
                transaction.accountId, 
                transaction.category, 
                amountDifference
              );
            }
          } 
          // If transaction type changed from income to expense
          else if (transaction.type == 'expense' && originalTrans.type == 'income') {
            await BudgetHelper.instance.adjustBudgetsForTransaction(
              txn, 
              transaction.accountId, 
              transaction.category, 
              transaction.amount
            );
          }
          // If transaction type changed from expense to income
          else if (transaction.type == 'income' && originalTrans.type == 'expense') {
            await BudgetHelper.instance.adjustBudgetsForTransaction(
              txn, 
              originalTrans.accountId, 
              originalTrans.category, 
              -originalTrans.amount
            );
          }
        }
      }
      
      await SavingsHelper.instance.updateSavingsGoalsFromAccounts(txn: txn);
      return updateResult;
    });
  }
  
  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    final db = await _baseHelper.database;
    
    return await db.transaction((sqflite.Transaction txn) async {
      // First get the transaction to adjust the account balance
      final transResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (transResult.isEmpty) {
        return 0; // Transaction not found
      }
      
      final trans = model.Transaction.fromMap(transResult.first);
      
      // Adjust account balance if applicable
      if (trans.accountId != null) {
        await AccountHelper.instance.adjustAccountBalance(
          txn,
          trans.accountId!,
          trans.type == 'income' ? -trans.amount : trans.amount,
        );
      }
      
      // If this is an expense, also adjust the budget(s)
      if (trans.type == 'expense') {
        await BudgetHelper.instance.adjustBudgetsForTransaction(
          txn, 
          trans.accountId, 
          trans.category, 
          -trans.amount // Subtract the amount from the budget
        );
      }
      await SavingsHelper.instance.updateSavingsGoalsFromAccounts(txn: txn);

      return await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
  
  // Delete all transactions
  Future<int> deleteAllTransactions() async {
    final db = await _baseHelper.database;
    
    // Start a transaction to ensure data consistency
    return await db.transaction((sqflite.Transaction txn) async {
      // Reset all account balances to zero
      await txn.update(
        'accounts',
        {'balance': 0.0},
      );
      
      // Reset all budget spent amounts to zero
      await txn.update(
        'budgets',
        {'spent': 0.0},
      );
      
      // Delete all transactions
      return await txn.delete('transactions');
    });
  }
}
