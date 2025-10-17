// lib/providers/transaction_provider.dart

import 'dart:ffi';

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
  double lends = 0.0;

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
    lends = await dbHelper.getLends();

    notifyListeners();
  }

  void deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    getTransactions();
    getSummary();
  }

  void addTransaction(TransactionModel newTransaction) async {
    await dbHelper.insertTransaction(
      newTransaction,
    ); // Add new transaction at the top
    getTransactions();
    getSummary();
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
