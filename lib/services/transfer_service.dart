// services/transfer_service.dart

import '../database/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class TransferService {
  static final TransferService instance = TransferService._init();
  
  TransferService._init();
  
  /// Transfers money from one account to another and logs it as two transactions
  Future<bool> transferBetweenAccounts({
    required int fromAccountId, 
    required int toAccountId, 
    required double amount, 
    String? notes
  }) async {
    if (fromAccountId == toAccountId) {
      return false; // Can't transfer to the same account
    }
    
    if (amount <= 0) {
      return false; // Amount must be positive
    }
    
    final db = await DatabaseHelper.instance.database;
    
    // Start a database transaction for atomicity
    return await db.transaction((txn) async {
      try {
        // Get source account
        final sourceAccountResult = await txn.query(
          'accounts',
          where: 'id = ?',
          whereArgs: [fromAccountId],
        );
        
        if (sourceAccountResult.isEmpty) {
          return false; // Source account not found
        }
        
        final sourceAccount = Account.fromMap(sourceAccountResult.first);
        
        // Verify sufficient balance
        if (sourceAccount.balance < amount) {
          return false; // Insufficient balance
        }
        
        // Get destination account
        final destAccountResult = await txn.query(
          'accounts',
          where: 'id = ?',
          whereArgs: [toAccountId],
        );
        
        if (destAccountResult.isEmpty) {
          return false; // Destination account not found
        }
        
        final destAccount = Account.fromMap(destAccountResult.first);
        
        // Create timestamp for both transactions
        final now = DateTime.now();
        
        // Create withdrawal transaction for source account
        final withdrawalTransaction = Transaction(
          title: 'Transfer to ${destAccount.name}',
          amount: amount,
          type: 'expense', // Treated as expense for source account
          category: 'Transfer',
          date: now,
          notes: notes ?? 'Transfer to ${destAccount.name}',
          accountId: fromAccountId,
        );
        
        // Create deposit transaction for destination account
        final depositTransaction = Transaction(
          title: 'Transfer from ${sourceAccount.name}',
          amount: amount,
          type: 'income', // Treated as income for destination account
          category: 'Transfer',
          date: now,
          notes: notes ?? 'Transfer from ${sourceAccount.name}',
          accountId: toAccountId,
        );
        
        // Update source account balance
        await txn.update(
          'accounts',
          {'balance': sourceAccount.balance - amount},
          where: 'id = ?',
          whereArgs: [fromAccountId],
        );
        
        // Update destination account balance
        await txn.update(
          'accounts',
          {'balance': destAccount.balance + amount},
          where: 'id = ?',
          whereArgs: [toAccountId],
        );
        
        // Insert the transactions
        await txn.insert('transactions', withdrawalTransaction.toMap());
        await txn.insert('transactions', depositTransaction.toMap());
        
        return true;
      } catch (e) {
        print('Error during transfer: $e');
        return false;
      }
    });
  }
}