import 'package:expense_tracer/models/transaction.dart';
import 'package:expense_tracer/widgets/lend_item.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../widgets/summary_card.dart';
import '../db/db_helper.dart';
import '../screens/add_transaction_page.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  late Future transactionsFuture;

  @override
  void initState() {
    super.initState();
    transactionsFuture = _loadTransactions();
  }

  Future _loadTransactions() {
    transactionsFuture = Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).getTransactions();
    print('inside home');
    return transactionsFuture;
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
        child: AddTransactionSheet(onTransactionAdded: () {}),
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
      body: FutureBuilder(
        future: transactionsFuture,
        builder: (ctx, snapshot) {
          // Show a loading spinner while waiting for data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if something went wrong.
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          return Consumer<TransactionProvider>(
            builder: (ctx, transactionProvider, child) {
              final transactions = transactionProvider.transactions;
              print('transactions');
              print(transactions);
              return transactions.isEmpty
                  ? const Center(child: Text('No transactions yet.'))
                  : HomeBody(transactions: transactions);
            },
          );
        },
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

class HomeBody extends StatelessWidget {
  late List<JoinedTransaction> transactions = [];

  List<Widget> cards = [
    SummaryCard(bgColor: Colors.indigo),
    SummaryCard(bgColor: Colors.pinkAccent),
  ];

  HomeBody({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200, // 👈 give it a fixed height
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return cards[index];
              },
              itemCount: cards.length,
              itemWidth: MediaQuery.of(context).size.width - 52,
              layout: SwiperLayout.STACK,
            ),
          ),
          // const SummaryCard(),
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
              return LendItem(lendTransaction: tx);
            },
          ),
        ],
      ),
    );
  }
}
