import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class SummaryCard extends StatefulWidget {
  final Color bgColor;
  const SummaryCard({super.key, required this.bgColor});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  final dbHelper = DatabaseHelper();

  late Future totalFuture;
  double expense = 0.0;
  double income = 0.0;
  double shopping = 0.0;
  double lends = 0.0;

  @override
  void initState() {
    super.initState();
    totalFuture = _obtainBalanceFuture();
    // _loadSummary();
  }

  Future _obtainBalanceFuture() {
    return Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).getSummary();
  }

  @override
  Widget build(BuildContext context) {
    final bdFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳');

    return Consumer<TransactionProvider>(
      builder: (ctx, transactionProvider, child) {
        final total = transactionProvider.total;
        final totalExpense = transactionProvider.expense * -1;
        final totalIncome = transactionProvider.deposit;
        final topay = transactionProvider.lends > 0;
        final totalLends =
            transactionProvider.lends *
            (topay || transactionProvider.lends == 0 ? 1 : -1);

        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              color: widget.bgColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      bdFormat.format(total),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SummaryItem(
                          label: "Income",
                          amount: bdFormat.format(totalIncome),
                          color: Colors.greenAccent,
                          icon: Icons.arrow_upward,
                        ),
                        _SummaryItem(
                          label: "Expense",
                          amount: bdFormat.format(totalExpense),
                          color: Colors.redAccent,
                          icon: Icons.arrow_downward,
                          rightEnd: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // 👈 aligns text to the right
                children: [
                  _SummaryItem(
                    label: topay ? "Payable" : "Recieveavle",
                    amount: bdFormat.format(totalLends),
                    color: topay ? Colors.red : Colors.greenAccent,
                    icon: Icons.arrow_upward,
                    rightEnd: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;
  final bool rightEnd;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.rightEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: rightEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  amount,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
