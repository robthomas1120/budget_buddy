// widgets/add_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class AddTransactionSheet extends StatefulWidget {
  final String transactionType;
  final Function onTransactionAdded;

  const AddTransactionSheet({
    Key? key,
    this.transactionType = '',
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _AddTransactionSheetState createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = '';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;
  List<Account> _accounts = [];
  bool _isLoadingAccounts = true;
  
  List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gift',
    'Other',
  ];
  
  List<String> _expenseCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Housing',
    'Shopping',
    'Utilities',
    'Healthcare',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transactionType.isEmpty ? 'income' : widget.transactionType;
    _selectedCategory = _selectedType == 'income' ? _incomeCategories[0] : _expenseCategories[0];
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });
    
    final accounts = await DatabaseHelper.instance.getAllAccounts();
    
    setState(() {
      _accounts = accounts;
      _isLoadingAccounts = false;
      if (accounts.isNotEmpty) {
        _selectedAccountId = accounts[0].id;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = _selectedType == 'income' ? _incomeCategories : _expenseCategories;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Transaction type toggle
              if (widget.transactionType.isEmpty) ...[
                Text('Transaction Type:'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = 'income';
                            _selectedCategory = _incomeCategories[0];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == 'income' ? Colors.green : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: _selectedType == 'income' ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = 'expense';
                            _selectedCategory = _expenseCategories[0];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == 'expense' ? Colors.red : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: _selectedType == 'expense' ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
              
              // Account dropdown
              _isLoadingAccounts
                  ? Center(child: CircularProgressIndicator())
                  : _accounts.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No accounts found',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // You should implement a way to add accounts
                                // You could navigate to AccountsPage or show a dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please add an account first')),
                                );
                              },
                              child: Text('Add Account'),
                            ),
                            SizedBox(height: 16),
                          ],
                        )
                      : DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'To/From Account',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedAccountId,
                          items: _accounts.map((Account account) {
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
                                  Text('${account.name} (₱${account.balance.toStringAsFixed(2)})'),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedAccountId = newValue;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an account';
                            }
                            return null;
                          },
                        ),
              SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (₱)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              
              // Date picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'income' ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _selectedAccountId != null) {
                      final transaction = Transaction(
                        title: _titleController.text,
                        amount: double.parse(_amountController.text),
                        type: _selectedType,
                        category: _selectedCategory,
                        date: _selectedDate,
                        notes: _notesController.text.isEmpty ? null : _notesController.text,
                        accountId: _selectedAccountId,
                      );
                      
                      await DatabaseHelper.instance.insertTransaction(transaction);
                      widget.onTransactionAdded();
                      Navigator.pop(context);
                    } else if (_selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an account')),
                      );
                    }
                  },
                  child: Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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