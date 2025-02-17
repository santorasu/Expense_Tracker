import 'package:expense_tracker/widget/ProfilePage.dart';
import 'package:flutter/material.dart';
import '../model/expense.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker App',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          color: Colors.green,
          centerTitle: true,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Expense> _expense = [];
  final List<String> _categories = [
    'Food',
    'Travel',
    'Entertainment',
    'Bills',
    'Transportation'
  ];
  double _total = 0.0;
  int _selectedIndex = 0;

  // Controllers for the form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addExpense(String title, double amount, DateTime date, String category) {
    setState(() {
      _expense.add(Expense(
          title: title, amount: amount, date: date, category: category));
      _total += amount;
    });
  }

  void _deleteExpense(int index) {
    setState(() {
      _total -= _expense[index].amount;
      _expense.removeAt(index);
    });
  }

  void _showForm(BuildContext context) {
    String? selectedCategory;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_titleController.text.isEmpty ||
                            _amountController.text.isEmpty ||
                            selectedCategory == null) {
                          return;
                        }
                        double? amount = double.tryParse(_amountController.text);
                        if (amount == null) {
                          return;
                        }
                        setState(() {
                          _addExpense(_titleController.text, amount,
                              selectedDate, selectedCategory!);
                        });
                        Navigator.of(context).pop();
                        _titleController.clear();
                        _amountController.clear();
                      },
                      child: const Text("Add Expense"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _showForm(context);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(20),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Total: \$${_total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _expense.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: Key(_expense[index].date.toString()),
                  background: Container(color: Colors.redAccent),
                  onDismissed: (direction) {
                    Future.delayed(Duration.zero, () {
                      _deleteExpense(index);
                    });
                  },
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Text(_expense[index].category[0]),
                      ),
                      title: Text(
                        _expense[index].title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                      Text(DateFormat.yMMMd().format(_expense[index].date)),
                      trailing: Text(
                        "\$${_expense[index].amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 40), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}