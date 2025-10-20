enum TransactionTypes { deposit, expense, lendGive, lendTake }

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final TransactionTypes type;
  int? lendID; // Foreign key

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.lendID,
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
      'LendID': lendID,
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
      lendID: map['LendID'],
    );
  }

  @override
  String toString() {
    return 'TransactionModel{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }
}

class JoinedTransaction {
  // Transaction fields
  final int transactionId;
  final String category;
  final String type;
  final DateTime createdDate;

  // Lend fields (nullable)
  final int? lendID;
  final String? personName;
  final DateTime? returnDate;
  final bool? returned;

  JoinedTransaction({
    required this.transactionId,
    required this.category,
    required this.type,
    required this.createdDate,
    this.lendID,
    this.personName,
    this.returnDate,
    this.returned,
  });

  factory JoinedTransaction.fromMap(Map<String, dynamic> map) {
    return JoinedTransaction(
      transactionId: map['t_id'], // Using alias from the query
      category: map['category'],
      type: map['type'],
      createdDate: DateTime.parse(map['created_date']),
      lendID: map['LendID'],
      personName: map['person_name'], // Will be null if no join
      returnDate: map['return_date'] != null
          ? DateTime.parse(map['return_date'])
          : null,
      returned: map['returned'] != null ? (map['returned'] == 1) : null,
    );
  }
}
