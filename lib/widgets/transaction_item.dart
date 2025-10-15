import 'package:expense_tracer/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final String category;
  final String type;

  const TransactionItem({
    super.key,
    required this.title,
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
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon(category);
    final color = _getCategoryColor(category);
    final isExpense = type == TransactionTypes.expense.name;
    final txAmount = isExpense ? -amount : amount;
    return SwipeActionCell(
      key: ObjectKey(title),
      trailingActions: <SwipeAction>[
        SwipeAction(
          content: _getIconButton(Colors.grey, Icons.edit),
          onTap: (CompletionHandler handler) async {
            handler(false); // false means don't close the cell
          },
          color: Colors.transparent,
        ),
        SwipeAction(
          content: _getIconButton(Colors.red, Icons.delete),
          onTap: (CompletionHandler handler) async {
            await handler(true);

            // Remove the item from your data source and update the UI
            // setState(() {
            //   _items.removeAt(index);
            // });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("$title deleted.")));
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
          title: Text(capitalize(title)),
          // subtitle: Text(
          //   "${date.toLocal().toString().split(' ')[0]} • $category",
          // ),
          subtitle: Text(
            '$category • ${DateFormat('MMM d, yyyy – hh:mm a').format(DateTime.parse(date))}',
            style: TextStyle(fontSize: 12),
          ),
          trailing: Text(
            "${isExpense ? '-' : '+'}\৳${txAmount.toStringAsFixed(2)}",
            style: TextStyle(
              color: isExpense ? Colors.redAccent : Colors.green,
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
