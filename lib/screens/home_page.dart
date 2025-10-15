import 'package:flutter/material.dart';
import '../widgets/transaction_item.dart';
import '../widgets/summary_card.dart';
import '../models/transaction.dart';
import '../db/db_helper.dart';
import '../screens/add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await dbHelper.getAllTransactions();
    setState(() {
      transactions = data;
    });
  }

  Future<void> _openAddTransaction() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets the sheet expand properly
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionSheet(onTransactionAdded: _loadTransactions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SummaryCard(),
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // prevent nested scroll conflict
              shrinkWrap: true, // let it fit inside the scroll view
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return TransactionItem(
                  title: tx.title,
                  amount: tx.amount,
                  category: tx.category,
                  date: tx.date,
                  type: tx.type.name,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// class HomeBody extends StatelessWidget {
//   const HomeBody({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SummaryCard(),
//           const SizedBox(height: 20),
//           const Text(
//             'Recent Transactions',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           ...List.generate(5, (index) => const TransactionItem())
//         ],
//       ),
//     );
//   }
// }
