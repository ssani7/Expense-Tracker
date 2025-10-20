import 'package:expense_tracer/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class AddTransactionSheet extends StatefulWidget {
  final VoidCallback onTransactionAdded;
  const AddTransactionSheet({Key? key, required this.onTransactionAdded})
    : super(key: key);

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '50',
  );
  final TextEditingController _personNameController = TextEditingController();
  final _categoryController = TextEditingController();

  TransactionTypes _transactionType = TransactionTypes.expense;
  String _selectedCategory = "Other";
  DateTime _selectedDateTime = DateTime.now();
  DateTime? _returnDate;
  bool _isLendMode = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _personNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _returnDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  void _increment(double value) {
    final current = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _amountController.text = (current + value).toStringAsFixed(2);
    });
  }

  void _decrement(double value) {
    final current = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      final newValue = (current - value) >= 0 ? current - value : 0;
      _amountController.text = newValue.toStringAsFixed(2);
    });
  }

  final List<String> _categories = [
    'Groceries',
    'Transport',
    'Bills',
    'Entertainment',
    'Loan',
    'Income',
  ];

  void _onCategorySelected(String category) {
    setState(() {
      // Check if the user is tapping the *already selected* chip
      if (_selectedCategory == category) {
        // If so, deselect it
        _selectedCategory = "";
        _categoryController.text = ""; // Clear the text field
      } else {
        // If tapping a new chip, select it
        _selectedCategory = category;
        _categoryController.text = category; // Update the text field
      }
    });
  }

  // ✅ Your provided function (unchanged, now fully working)
  Future<void> _saveTransaction() async {
    final newTx = JoinedTransaction(
      category: _selectedCategory,
      date: _selectedDateTime.toIso8601String(),
      type: _transactionType,
      amount:
          (_transactionType == TransactionTypes.expense ||
              _transactionType == TransactionTypes.lendGive)
          ? double.parse(_amountController.text) * -1
          : double.parse(_amountController.text),
      person_name: _personNameController.text.trim(),
      return_date: _returnDate?.toIso8601String(),
    );

    widget.onTransactionAdded();
    context.read<TransactionProvider>().addTransaction(newTx);
    Navigator.pop(context);
  }

  void _openCalculator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        double currentValue = double.tryParse(_amountController.text) ?? 0.0;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: SimpleCalculator(
            value: currentValue,
            hideExpression: false,
            hideSurroundingBorder: true,
            autofocus: true,
            theme: const CalculatorThemeData(
              borderColor: Colors.black12,
              displayColor: Colors.white,
              displayStyle: TextStyle(fontSize: 48, color: Colors.black),
              expressionColor: Colors.black26,
              expressionStyle: TextStyle(fontSize: 24, color: Colors.grey),
              operatorColor: Colors.green,
              commandColor: Colors.orange,
              numColor: Colors.white,
              operatorStyle: TextStyle(fontSize: 28, color: Colors.white),
              commandStyle: TextStyle(fontSize: 22, color: Colors.white),
              numStyle: TextStyle(fontSize: 22, color: Colors.black),
            ),
            onChanged: (key, value, expression) {
              // Called when any button is pressed, including "="
              if (key == '=') {
                setState(() {
                  _amountController.text = value!.toStringAsFixed(2);
                });
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 🏷️ Title input
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0, // Horizontal space between chips
                  runSpacing: 4.0, // Vertical space between lines
                  children: _categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      // Set the selected state based on our state variable
                      selected: _selectedCategory == category,
                      // Handle the tap event
                      onSelected: (isSelected) {
                        // We use our custom function to handle logic
                        _onCategorySelected(category);
                      },
                      // Optional: Add styling for the selected chip
                      selectedColor: Colors.blue[100],
                      labelStyle: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.blue[900]
                            : Colors.black,
                      ),
                    );
                  }).toList(),
                ),

                // 💰 Amount section
                const Text(
                  'Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _decrement(100),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      onPressed: () => _decrement(10),
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter amount';
                          if (double.tryParse(val) == null)
                            return 'Invalid number';
                          return null;
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _increment(10),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () => _increment(100),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calculate_rounded),
                      onPressed: _openCalculator,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🕒 Date time picker
                const Text(
                  'Date & Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(dateFormat.format(_selectedDateTime))),
                    ElevatedButton(
                      onPressed: _pickDateTime,
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 💵 Transaction Type
                const Text(
                  'Transaction Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildTypeButton('Deposit', TransactionTypes.deposit),
                    _buildTypeButton('Expense', TransactionTypes.expense),
                    _buildTypeButton('Lend', TransactionTypes.lendGive),
                  ],
                ),

                if (_transactionType == TransactionTypes.lendGive ||
                    _transactionType == TransactionTypes.lendTake)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        children: [
                          _buildTypeButton('Give', TransactionTypes.lendGive),
                          _buildTypeButton('Take', TransactionTypes.lendTake),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _personNameController,
                        decoration: const InputDecoration(
                          labelText: 'Person Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if ((_transactionType == TransactionTypes.lendGive ||
                                  _transactionType ==
                                      TransactionTypes.lendTake) &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Please enter the person\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _returnDate != null
                                  ? 'Return Date: ${dateFormat.format(_returnDate!)}'
                                  : 'Return Date: Not set',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _pickReturnDate,
                            child: const Text('Pick Date'),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Save Transaction'),
                  onPressed: _saveTransaction,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(String label, TransactionTypes type) {
    final isSelected = _transactionType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.indigo : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          if (type == TransactionTypes.lendGive ||
              type == TransactionTypes.lendTake) {
            _isLendMode = true;
          } else {
            _isLendMode = false;
          }
          _transactionType = type;
        });
      },
      child: Text(label),
    );
  }
}

// 🚀 To show the sheet
void showAddTransactionSheet(
  BuildContext context,
  VoidCallback onTransactionAdded,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        AddTransactionSheet(onTransactionAdded: onTransactionAdded),
  );
}
