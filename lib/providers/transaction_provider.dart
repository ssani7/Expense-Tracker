// lib/providers/transaction_provider.dart

import 'dart:ffi';

import 'package:expense_tracer/models/lend.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart'; // Make sure this path is correct
import '../db/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<JoinedTransaction> _transactions = [];
  List<JoinedTransaction> get transactions {
    return [..._transactions];
  }

  List<JoinedTransaction> _lendTransactions = [];
  List<JoinedTransaction> get lendTransactions {
    return [..._lendTransactions];
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

  Future<void> updateAll() async {
    getTransactions();
    getLendTransactions();
    getSummary();
    notifyListeners();
  }

  Future<void> getLendTransactions() async {
    _lendTransactions = await dbHelper.getAllLends();
    notifyListeners();
  }

  Future<void> getSummary() async {
    total = await dbHelper.getBanlance();
    expense = await dbHelper.getExpense();
    deposit = await dbHelper.getIncome();
    lends = await dbHelper.getLendsAmount();

    notifyListeners();
  }

  void deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    updateAll();
  }

  void retrunLend(int id) async {
    int result = await dbHelper.returnLend(id);
    print('updated');
    print(result);

    updateAll();
  }

  void addTransaction(JoinedTransaction newTransaction) async {
    if (newTransaction.type == TransactionTypes.lendGive ||
        newTransaction.type == TransactionTypes.lendTake) {
      int id = await dbHelper.addLend(
        Lend(
          personName: newTransaction?.person_name,
          returnDate: newTransaction?.return_date,
        ),
      );
      newTransaction.lendID = id;
    }
    await dbHelper.insertTransaction(
      newTransaction.joinedToTransaction(newTransaction),
    ); // Add new transaction at the top
    updateAll();
  }

  // You can add your edit logic here as well
  // void editTransaction(String id, TransactionModel updatedTransaction) {
  //   final txIndex = _transactions.indexWhere((tx) => tx.id == id);
  //   if (txIndex >= 0) {
  //     _transactions[txIndex] = updatedTransaction;
  //     notifyListeners();
  //   }
  // }
}
