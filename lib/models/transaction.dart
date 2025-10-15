class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Convert a Transaction object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
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
    );
  }

  @override
  String toString() {
    return 'TransactionModel{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }
}
