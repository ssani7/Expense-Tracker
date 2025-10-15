enum TransactionTypes { deposit, expense }

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final TransactionTypes type;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  // Convert a Transaction object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'type': type.name,
    };
  }

  // Convert a Map into a Transaction object.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'] as double,
      category: map['category'] as String,
      date: map['date'] as String,
      type: TransactionTypes.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionTypes.expense, // fallback
      ),
    );
  }

  @override
  String toString() {
    return 'TransactionModel{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }
}
