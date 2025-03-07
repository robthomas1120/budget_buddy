// models/account.dart

class Account {
  final int? id;
  final String name;
  final String type; // 'bank', 'e-wallet', 'cash', etc.
  final String? iconName;
  double balance;

  Account({
    this.id,
    required this.name,
    required this.type,
    this.iconName,
    required this.balance,
  });

  // Convert an Account into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon_name': iconName,
      'balance': balance,
    };
  }

  // Create an Account from a Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      iconName: map['icon_name'],
      balance: map['balance'],
    );
  }

  // Create a copy of this Account with the given field values changed
  Account copyWith({
    int? id,
    String? name,
    String? type,
    String? iconName,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      balance: balance ?? this.balance,
    );
  }
}