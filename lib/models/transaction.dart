//transaction.dart

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final String type;  // 'income' or 'expense'
  final String category;
  final DateTime date;
  final String? notes;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
  });

  // Convert a Transaction into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  // Create a Transaction from a Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'],
    );
  }

  // Create a copy of this Transaction with the given field values changed
  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}