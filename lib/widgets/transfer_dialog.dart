import 'package:flutter/cupertino.dart';
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
  void initState() {
    super.initState();
    if (widget.accounts.length >= 2) {
      _fromAccountId = widget.accounts[0].id;
      _toAccountId = widget.accounts[1].id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.xmark, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              Divider(height: 24),
              
              // From Account
              Text(
                'From Account:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              _buildAccountSelector(
                currentValue: _fromAccountId,
                onChanged: (value) {
                  setState(() {
                    _fromAccountId = value;
                    if (_toAccountId == value) {
                      _toAccountId = widget.accounts.firstWhere((account) => account.id != value).id;
                    }
                    _errorMessage = null;
                  });
                },
                excludeId: _toAccountId,
              ),
              SizedBox(height: 16),
              
              // To Account
              Text(
                'To Account:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              _buildAccountSelector(
                currentValue: _toAccountId,
                onChanged: (value) {
                  setState(() {
                    _toAccountId = value;
                    if (_fromAccountId == value) {
                      _fromAccountId = widget.accounts.firstWhere((account) => account.id != value).id;
                    }
                    _errorMessage = null;
                  });
                },
                excludeId: _fromAccountId,
              ),
              SizedBox(height: 16),
              
              // Amount Field
              Text(
                'Amount:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: _amountController,
                placeholder: '0.00',
                prefix: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text('₱', style: TextStyle(color: CupertinoColors.black)),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              SizedBox(height: 16),
              
              // Notes Field
              Text(
                'Notes (optional):',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: _notesController,
                placeholder: 'Add notes about this transfer',
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              
              // Error message if any
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: CupertinoColors.destructiveRed,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      color: CupertinoColors.systemGrey6,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      onPressed: _isProcessing ? null : _processTransfer,
                      child: _isProcessing
                          ? CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text('Transfer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelector({
    required int? currentValue,
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

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentValue,
          isExpanded: true,
          icon: Icon(CupertinoIcons.chevron_down, size: 16),
          style: TextStyle(
            color: CupertinoColors.black,
            fontSize: 16,
          ),
          dropdownColor: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(8),
          items: availableAccounts.map((Account account) {
            return DropdownMenuItem<int>(
              value: account.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getAccountColor(account.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₱${account.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
      
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Success'),
          content: Text('Transfer completed successfully'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
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
        return CupertinoIcons.building_2_fill;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoIcons.creditcard_fill;
      case 'cash':
        return CupertinoIcons.money_dollar_circle_fill;
      default:
        return CupertinoIcons.creditcard_fill;
    }
  }

  Color _getAccountColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return CupertinoColors.systemBlue;
      case 'e-wallet':
      case 'ewallet':
        return CupertinoColors.systemPurple;
      case 'cash':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemIndigo;
    }
  }
}