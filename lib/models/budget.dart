// lib/models/budget.dart

class Budget {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final String period; // 'weekly' or 'monthly'
  final DateTime startDate;
  final DateTime endDate;
  double spent;
  final List<int>? accountIds; // List of account IDs included in this budget
  
  Budget({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.spent = 0.0,
    this.accountIds,
  });
  
  // Convert a Budget to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'period': period,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'spent': spent,
      'account_ids': accountIds != null ? accountIds!.join(',') : null,
    };
  }
  
  // Create a Budget from a Map
  factory Budget.fromMap(Map<String, dynamic> map) {
    List<int>? parsedAccountIds;
    if (map['account_ids'] != null && map['account_ids'].toString().isNotEmpty) {
      parsedAccountIds = map['account_ids'].toString().split(',').map((id) => int.parse(id)).toList();
    }
    
    return Budget(
      id: map['id'],
      title: map['title'] ?? map['category'], // Fallback for older records
      category: map['category'],
      amount: map['amount'],
      period: map['period'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date']),
      spent: map['spent'] ?? 0.0,
      accountIds: parsedAccountIds,
    );
  }
  
  // Create a copy of this Budget with the given field values changed
  Budget copyWith({
    int? id,
    String? title,
    String? category,
    double? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    double? spent,
    List<int>? accountIds,
  }) {
    return Budget(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spent: spent ?? this.spent,
      accountIds: accountIds ?? this.accountIds,
    );
  }
  
  // Calculate remaining budget
  double get remaining => amount - spent;
  
  // Calculate progress percentage (0.0 to 1.0)
  double get progress => spent / amount;
  
  // Determine if budget is over limit
  bool get isOverBudget => spent > amount;
  
  // Check if budget period has ended
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  // Check if budget is active
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
}