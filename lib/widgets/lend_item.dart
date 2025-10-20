import 'package:expense_tracer/models/transaction.dart';
import 'package:expense_tracer/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:provider/provider.dart';

class LendItem extends StatelessWidget {
  final JoinedTransaction lendTransaction;

  const LendItem({super.key, required this.lendTransaction});

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
      case "income":
        return Icons.money;
      case "other":
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(TransactionTypes type) {
    if (type == TransactionTypes.expense || type == TransactionTypes.lendGive) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  String capitalize(text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  String formatToBDT(amount) {
    final bdFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳');

    return bdFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isLend = lendTransaction.lendID != null;
    final isReturned = lendTransaction.returned == true;
    final icon = isReturned
        ? Icons.check
        : _getCategoryIcon(lendTransaction.category);
    final color = isReturned
        ? Colors.green
        : _getCategoryColor(lendTransaction.type);
    final isNegative = lendTransaction.amount < 0;

    return SwipeActionCell(
      key: ObjectKey(lendTransaction.category),
      trailingActions: <SwipeAction>[
        if (isLend && !isReturned)
          SwipeAction(
            content: _getIconButton(Colors.green, Icons.check),
            onTap: (CompletionHandler handler) async {
              handler(false); // false means don't close the cell
              context.read<TransactionProvider>().retrunLend(
                lendTransaction.lendID!,
              );
            },
            color: Colors.transparent,
          ),
        SwipeAction(
          content: _getIconButton(Colors.red, Icons.delete),
          onTap: (CompletionHandler handler) async {
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: Text(
                  'Are you sure you want to delete "$lendTransaction.category" '
                  '($lendTransaction.amount)?',
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

              context.read<TransactionProvider>().deleteTransaction(
                lendTransaction.id!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$lendTransaction.category deleted.")),
              );
            }
          },
          color: Colors.transparent,
        ),
      ],
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: isReturned ? Colors.green[100] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 1),
            foregroundColor: color,
            radius: 24,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          title: Text(
            '${capitalize(lendTransaction.category)} ${isLend ? '- ${lendTransaction.person_name}' : ''}',
          ),
          subtitle: Text(
            DateFormat(
              'MMM d, yyyy – hh:mm a',
            ).format(DateTime.parse(lendTransaction.date)),
            style: TextStyle(fontSize: 12),
          ),
          trailing: Text(
            '${!isNegative ? '+' : ''}${formatToBDT(lendTransaction.amount)}',
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
