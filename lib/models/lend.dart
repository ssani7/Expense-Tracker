// --- Model for Lend Table ---
class Lend {
  int? id;
  String? personName;
  String? returnDate;
  bool returned; // 0 = false, 1 = true

  Lend({this.id, this.personName, this.returnDate, this.returned = false});

  // Convert a Lend object into a Map.
  // Used when inserting/updating data in the database.
  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'person_name': personName,
      'return_date': returnDate,
      // .toIso8601String(), // Store DateTime as ISO String (TEXT)
      'returned': returned ? 1 : 0, // Store bool as INTEGER (0 or 1)
    };
  }

  // Convert a Map into a Lend object.
  // Used when reading data from the database.
  factory Lend.fromMap(Map<String, dynamic> map) {
    return Lend(
      id: map['Id'],
      personName: map['person_name'],
      returnDate: map['return_date'],
      returned: map['returned'] == 1,
    );
  }
}
