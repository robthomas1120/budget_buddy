// widgets/transfer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/account.dart';
import '../services/transfer_service.dart';
import '../utils/ios_theme.dart';

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
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center title
                  Text(
                    'Transfer Money',
                    style: IOSTheme.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  // Close button (right aligned)
                  Positioned(
                    right: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: Icon(CupertinoIcons.xmark, size: 20, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, thickness: 0.5, color: IOSTheme.borderColor),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Account
                      Text('From Account:', style: IOSTheme.bodyStyle),
                      SizedBox(height: 8),
                      _buildAccountDropdown(
                        currentValue: _fromAccountId,
                        onChanged: (value) {
                          setState(() {
                            _fromAccountId = value;
                            if (_toAccountId == value) {
                              _toAccountId = null;
                            }
                            _errorMessage = null;
                          });
                        },
                        excludeId: _toAccountId,
                      ),
                      SizedBox(height: 16),
                      
                      // To Account
                      Text('To Account:', style: IOSTheme.bodyStyle),
                      SizedBox(height: 8),
                      _buildAccountDropdown(
                        currentValue: _toAccountId,
                        onChanged: (value) {
                          setState(() {
                            _toAccountId = value;
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
                      Text('Amount:', style: IOSTheme.bodyStyle),
                      SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        placeholder: '0.00',
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('₱', style: IOSTheme.bodyStyle),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: IOSTheme.borderColor, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (_) => setState(() => _errorMessage = null),
                      ),
                      SizedBox(height: 16),
                      
                      // Notes Field
                      Text('Notes (optional):', style: IOSTheme.bodyStyle),
                      SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _notesController,
                        placeholder: 'Add notes about this transfer',
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        maxLines: 3,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: IOSTheme.borderColor, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Error message if any
                      if (_errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: IOSTheme.destructiveColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: IOSTheme.destructiveColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom buttons with iOS style
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _isProcessing ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: IOSTheme.secondaryColor,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      color: IOSTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: _isProcessing ? null : _processTransfer,
                      child: _isProcessing
                          ? CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              'Transfer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

    // Find selected account for display
    Account? selectedAccount;
    if (currentValue != null) {
      selectedAccount = widget.accounts.firstWhere(
        (account) => account.id == currentValue,
        orElse: () => widget.accounts.first,
      );
    }

    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 250,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey5,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text('Select Account', style: IOSTheme.titleStyle),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text('Done'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      onChanged(availableAccounts[index].id);
                    },
                    children: availableAccounts.map((Account account) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getAccountIcon(account.type),
                              color: _getAccountColor(account.type),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              account.name,
                              style: IOSTheme.bodyStyle,
                            ),
                            Spacer(),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: IOSTheme.borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedAccount != null
                  ? Row(
                      children: [
                        Icon(
                          _getAccountIcon(selectedAccount.type),
                          color: _getAccountColor(selectedAccount.type),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          selectedAccount.name,
                          style: IOSTheme.bodyStyle,
                        ),
                        Spacer(),
                        Text(
                          '₱${selectedAccount.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedAccount.balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select an account',
                      style: TextStyle(
                        color: CupertinoColors.placeholderText,
                      ),
                    ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
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