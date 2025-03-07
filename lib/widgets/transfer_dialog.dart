// widgets/transfer_dialog.dart

import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/transfer_service.dart';

class TransferDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function onTransferComplete;

  const TransferDialog({
    Key? key,
    required this.accounts,
    required this.onTransferComplete,
  }) : super(key: key);

  @override
  _TransferDialogState createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  int? _fromAccountId;
  int? _toAccountId;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transfer Money',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 8),
              
              // From Account Dropdown
              Text('From Account:'),
              SizedBox(height: 8),
              _buildAccountDropdown(
                currentValue: _fromAccountId,
                onChanged: (value) {
                  setState(() {
                    _fromAccountId = value;
                    // Reset toAccountId if it's the same as fromAccountId
                    if (_toAccountId == value) {
                      _toAccountId = null;
                    }
                    _errorMessage = null;
                  });
                },
                excludeId: _toAccountId,
              ),
              SizedBox(height: 16),
              
              // To Account Dropdown
              Text('To Account:'),
              SizedBox(height: 8),
              _buildAccountDropdown(
                currentValue: _toAccountId,
                onChanged: (value) {
                  setState(() {
                    _toAccountId = value;
                    // Reset fromAccountId if it's the same as toAccountId
                    if (_fromAccountId == value) {
                      _fromAccountId = null;
                    }
                    _errorMessage = null;
                  });
                },
                excludeId: _fromAccountId,
              ),
              SizedBox(height: 16),
              
              // Amount Field
              Text('Amount:'),
              SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: '₱ ',
                  hintText: '0.00',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              SizedBox(height: 16),
              
              // Notes Field
              Text('Notes (optional):'),
              SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this transfer',
                ),
              ),
              SizedBox(height: 16),
              
              // Error message if any
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.red.shade50,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processTransfer,
                    child: _isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Transfer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown({
    int? currentValue,
    required Function(int?) onChanged,
    int? excludeId,
  }) {
    // Filter accounts to exclude the one selected in the other dropdown
    final availableAccounts = widget.accounts
        .where((account) => account.id != excludeId)
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentValue,
          isExpanded: true,
          hint: Text('Select an account'),
          items: availableAccounts.map((Account account) {
            return DropdownMenuItem<int>(
              value: account.id,
              child: Row(
                children: [
                  Icon(
                    _getAccountIcon(account.type),
                    color: _getAccountColor(account.type),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      account.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₱${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _processTransfer() async {
    // Validate inputs
    if (_fromAccountId == null) {
      setState(() => _errorMessage = 'Please select a source account');
      return;
    }
    
    if (_toAccountId == null) {
      setState(() => _errorMessage = 'Please select a destination account');
      return;
    }
    
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Please enter an amount');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }
    
    if (amount <= 0) {
      setState(() => _errorMessage = 'Amount must be greater than zero');
      return;
    }
    
    // Check if source account has sufficient balance
    final sourceAccount = widget.accounts.firstWhere((a) => a.id == _fromAccountId);
    if (sourceAccount.balance < amount) {
      setState(() => _errorMessage = 'Insufficient balance in ${sourceAccount.name}');
      return;
    }
    
    // Start processing
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    // Perform the transfer
    final success = await TransferService.instance.transferBetweenAccounts(
      fromAccountId: _fromAccountId!,
      toAccountId: _toAccountId!,
      amount: amount,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );
    
    if (!mounted) return;
    
    if (success) {
      widget.onTransferComplete();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to complete transfer. Please try again.';
      });
    }
  }

  IconData _getAccountIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'cash':
        return Icons.money;
      default:
        return Icons.credit_card;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Colors.blue;
      case 'e-wallet':
      case 'ewallet':
        return Colors.purple;
      case 'cash':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}