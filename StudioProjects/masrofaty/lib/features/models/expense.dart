class Expense {
  final int? id;
  final String title;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final String currency;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
    required this.createdAt,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'currency': currency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      categoryId: map['category_id']?.toInt() ?? 0,
      date: DateTime.parse(map['date']),
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      currency: map['currency'] ?? 'ريال يمني',
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date, description: $description, createdAt: $createdAt, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.categoryId == categoryId &&
        other.date == date &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        categoryId.hashCode ^
        date.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        currency.hashCode;
  }
}
