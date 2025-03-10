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

  SavingsGoal({
    this.id,
    required this.name,
    required this.reason,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    required this.targetDate,
    this.accountId,
  });

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
    );
  }
}