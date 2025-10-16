// lib/providers/transaction_provider.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart'; // Make sure this path is correct
import '../db/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions {
    return [..._transactions];
  }

  double total = 0.0;
  double expense = 0.0;
  double deposit = 0.0;

  final dbHelper = DatabaseHelper();

  // --- Business Logic Methods ---

  Future<void> getTransactions() async {
    _transactions = await dbHelper.getAllTransactions();
    notifyListeners();
  }

  Future<void> getSummary() async {
    total = await dbHelper.getBanlance();
    expense = await dbHelper.getExpense();
    deposit = await dbHelper.getIncome();
    print('get balance called');
    print(total);
    // This is the crucial part: it tells any listening widgets to rebuild.
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    // This is the crucial part: it tells any listening widgets to rebuild.
    notifyListeners();
  }

  void addTransaction(TransactionModel newTransaction) async {
    await dbHelper.insertTransaction(
      newTransaction,
    ); // Add new transaction at the top
    print('addTransaction called');
    getTransactions();
    getSummary();
    notifyListeners();
  }

  // You can add your edit logic here as well
  void editTransaction(String id, TransactionModel updatedTransaction) {
    final txIndex = _transactions.indexWhere((tx) => tx.id == id);
    if (txIndex >= 0) {
      _transactions[txIndex] = updatedTransaction;
      notifyListeners();
    }
  }
}
