import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/transaction.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  final VoidCallback onTransactionAdded;
  const AddTransactionSheet({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Other';
  TransactionTypes _transactionType = TransactionTypes.expense;

  final _dbHelper = DatabaseHelper();

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final newTx = TransactionModel(
        title: _titleController.text,
        category: _selectedCategory,
        date: DateTime.now().toIso8601String(),
        type: _transactionType,
        amount: _transactionType == TransactionTypes.expense
            ? double.parse(_amountController.text) * -1
            : double.parse(_amountController.text),
      );

      // await _dbHelper.insertTransaction(newTx);

      print('amount');
      print(newTx.amount);
      widget.onTransactionAdded();
      context.read<TransactionProvider>().addTransaction(newTx);
      Navigator.pop(context);
      // setState(() {
      //   // Triggers build() and your SummaryCard will reload
      // });
    }
  }

  Widget _buildExpenseTypeButton() {
    final bool isSelected = _transactionType == TransactionTypes.expense;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _transactionType = TransactionTypes.expense;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                Icons.money_off,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 5),
              Text(
                'Expense',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositTypeButton() {
    final bool isSelected = _transactionType == TransactionTypes.deposit;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _transactionType = TransactionTypes.deposit;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                Icons.attach_money,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 5),
              Text(
                'Deposit',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildExpenseTypeButton(), _buildDepositTypeButton()],
            ),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a title' : null,
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter an amount' : null,
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryButton('Food', Icons.restaurant),
                const SizedBox(width: 8),
                _buildCategoryButton('Transport', Icons.directions_bus),
                const SizedBox(width: 8),
                _buildCategoryButton('Shopping', Icons.shopping_bag),
                const SizedBox(width: 8),
                _buildCategoryButton('Other', Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
