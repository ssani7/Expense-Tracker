import 'package:expense_tracer/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (ctx) => TransactionProvider(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}
