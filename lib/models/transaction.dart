enum TransactionTypes { deposit, expense, lendGive, lendTake }

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final TransactionTypes type;
  final int? LendID;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.LendID,
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
      'LendID': LendID,
    };
  }

  // Convert a Map into a Transaction object.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      LendID: map['LendID'] as int?,
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

class JoinedTransaction {
  // Transaction fields
  final int? id;
  final double amount;
  final String category;
  final TransactionTypes type;
  final String date;

  // Lend fields (nullable)
  int? lendID;
  final String? return_date;
  final String? person_name;
  final bool? returned;

  JoinedTransaction({
    this.id,
    required this.category,
    required this.type,
    required this.date,
    required this.amount,
    this.lendID,
    this.return_date,
    this.person_name,
    this.returned,
  });

  // Convert a Transaction object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'type': type.name,
      'LendID': lendID,
      'return_date': return_date,
      'person_name': person_name,
      'returned': returned,
    };
  }

  factory JoinedTransaction.fromMap(Map<String, dynamic> map) {
    return JoinedTransaction(
      id: map['id'], // Using alias from the query
      category: map['category'],
      type: TransactionTypes.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionTypes.expense, // fallback
      ),
      amount: map['amount'],
      date: map['date'],
      lendID: map['LendID'],
      person_name: map['person_name'], // Will be null if no join
      return_date: map['return_date'],
      returned: map['returned'] != null ? (map['returned'] == 1) : null,
    );
  }

  TransactionModel joinedToTransaction(JoinedTransaction joined) {
    return TransactionModel(
      id: joined.id,
      title: joined.person_name != null && joined.person_name!.isNotEmpty
          ? '${joined.category} (${joined.person_name})'
          : joined.category,
      amount: joined.amount,
      category: joined.category,
      date: joined.date,
      type: joined.type,
      LendID: joined.lendID,
    );
  }

  // @override
  // String toString() {
  //   return 'JoinedTransaction{id: $id, amount: $amount, category: $category, date: $date}';
  // }
}
