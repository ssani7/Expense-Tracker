import 'package:expense_tracer/models/lend.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  final tableLend = 'lends';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('transactions.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableLend (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        return_date TEXT NOT NULL,
        returned INTEGER NOT NULL DEFAULT 0 
      )
      ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',uuuu
        LendID INTEGER,
        FOREIGN KEY (LendID) REFERENCES $tableLend (Id) ON DELETE SET NULL
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> addLend(Lend lend) async {
    Database db = await database;
    return await db.insert(tableLend, lend.toMap());
  }

  Future<double> getBanlance() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions',
    );
    double total = result[0]['total'] != null
        ? result[0]['total'] as double
        : 0.0;
    return total;
  }

  Future<double> getExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = \'expense\'',
    );
    double total = result[0]['total'] != null
        ? result[0]['total'] as double
        : 0.0;
    return total;
  }

  Future<double> getIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = \'deposit\'',
    );
    double total = result[0]['total'] != null
        ? result[0]['total'] as double
        : 0.0;
    return total;
  }

  Future<double> getLends() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE (type = \'lendGive\' OR type = \'lendTake\')',
    );
    double total = result[0]['total'] != null
        ? result[0]['total'] as double
        : 0.0;
    return total;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
