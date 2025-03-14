// lib/models/savings_goal.dart

class SavingsGoal {
  final int? id;
  final String name;
  final String reason;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime targetDate;
  final int? accountId;
  final bool isActive;

  SavingsGoal({
    this.id,
    required this.name,
    required this.reason,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    required this.targetDate,
    this.accountId,
    this.isActive = true,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reason': reason,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'start_date': startDate.millisecondsSinceEpoch,
      'target_date': targetDate.millisecondsSinceEpoch,
      'account_id': accountId,
      'is_active': isActive ? 1 : 0,
    };
  }
    factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      reason: map['reason'] ?? '',
      targetAmount: map['target_amount'],
      currentAmount: map['current_amount'] ?? 0.0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date']),
      accountId: map['account_id'],
      isActive: map['is_active'] == null ? true : map['is_active'] == 1,
    );
  }

  // Calculate days remaining
  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  // Calculate daily savings needed
  double get dailySavingsNeeded {
    final remainingAmount = targetAmount - currentAmount;
    if (daysRemaining <= 0) return remainingAmount;
    return remainingAmount / daysRemaining;
  }

  // Calculate weekly savings needed
  double get weeklySavingsNeeded {
    return dailySavingsNeeded * 7;
  }

  // Calculate monthly savings needed
  double get monthlySavingsNeeded {
    return dailySavingsNeeded * 30;
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }
  
  // Create a copy with some fields updated
  SavingsGoal copyWith({
    int? id,
    String? name,
    String? reason,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? targetDate,
    int? accountId,
    bool? isActive,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      reason: reason ?? this.reason,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      accountId: accountId ?? this.accountId,
      isActive: isActive ?? this.isActive,
    );
  }
}