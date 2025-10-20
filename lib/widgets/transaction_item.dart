import 'package:expense_tracer/models/transaction.dart';
import 'package:expense_tracer/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final int id;
  final double amount;
  final String date;
  final String category;
  final String type;

  const TransactionItem({
    super.key,
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return Icons.fastfood;
      case "transport":
        return Icons.directions_car;
      case "shopping":
        return Icons.shopping_bag;
      case "bills":
        return Icons.receipt_long;
      case "other":
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return Colors.orangeAccent;
      case "transport":
        return Colors.blueAccent;
      case "shopping":
        return Colors.purpleAccent;
      case "bills":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String capitalize(text) {
    // return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
    return text;
  }

  String formatToBDT(amount) {
    final bdFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳');

    return bdFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon(category);
    final color = _getCategoryColor(category);
    final isNegative = amount < 0;

    return SwipeActionCell(
      key: ObjectKey(category),
      trailingActions: <SwipeAction>[
        // SwipeAction(
        //   content: _getIconButton(Colors.grey, Icons.edit),
        //   onTap: (CompletionHandler handler) async {
        //     handler(false); // false means don't close the cell
        //   },
        //   color: Colors.transparent,
        // ),
        SwipeAction(
          content: _getIconButton(Colors.red, Icons.delete),
          onTap: (CompletionHandler handler) async {
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: Text(
                  'Are you sure you want to delete "$category" '
                  '($amount)?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false), // Cancel
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => Navigator.pop(context, true), // Confirm
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            // If confirmed, delete the transaction
            if (confirmed == true) {
              await handler(true);

              context.read<TransactionProvider>().deleteTransaction(id);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("$category deleted.")));
            }
          },
          color: Colors.transparent,
        ),
      ],
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(capitalize(category)),
          subtitle: Text(
            DateFormat('MMM d, yyyy – hh:mm a').format(DateTime.parse(date)),
            style: TextStyle(fontSize: 12),
          ),
          trailing: Text(
            '${!isNegative ? '+' : ''}${formatToBDT(amount)}',
            style: TextStyle(
              color: isNegative ? Colors.redAccent : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIconButton(color, icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        /// set you real bg color in your content
        color: color,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
