import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final String category;

  const TransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
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
    return Card(
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
        ),
        trailing: Text(
          "-\৳${amount.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
