import 'package:flutter/material.dart';
import '../model/expense.dart';

class ProfilePage extends StatefulWidget {
  final List<Expense> expenses;

  const ProfilePage({super.key, required this.expenses});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Map<String, double> _calculateCategoryPercentages() {
    Map<String, double> categoryTotals = {};

    for (var expense in widget.expenses) {
      categoryTotals.update(
        expense.category,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotals;
  }

  Map<String, double> _calculateCategoryPercentagesWithTotal(double total) {
    Map<String, double> categoryPercentages = {};

    Map<String, double> categoryTotals = _calculateCategoryPercentages();

    for (var category in categoryTotals.keys) {
      double percentage = (categoryTotals[category]! / total) * 100;
      categoryPercentages[category] = percentage;
    }

    return categoryPercentages;
  }

  final Map<String, Color> _categoryColors = {
    'Food': Colors.red,
    'Travel': Colors.blue,
    'Entertainment': Colors.green,
    'Bills': Colors.orange,
    'Transportation': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    double totalExpenses = widget.expenses.fold(0, (sum, expense) => sum + expense.amount);

    Map<String, double> categoryPercentages = _calculateCategoryPercentagesWithTotal(totalExpenses);

    var sortedCategories = categoryPercentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 0),
              SizedBox(
                width: 250,
                height: 250,
                child: Center(

                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.transparent,
                        strokeWidth: 20,
                      ),
                      ..._buildCategorySegments(sortedCategories),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...sortedCategories.map((entry) {
                String category = entry.key;
                double percentage = entry.value;

                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    color: _categoryColors[category] ?? Colors.grey,
                  ),
                  title: Text(category),
                  trailing: Text("${percentage.toStringAsFixed(1)} %"),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategorySegments(List<MapEntry<String, double>> categories) {
    List<Widget> segments = [];
    double startAngle = -90;

    for (var entry in categories) {
      String category = entry.key;
      double percentage = entry.value;

      double sweepAngle = (percentage / 100) * 360;

      // Add the segment
      segments.add(
        Transform.rotate(
          angle: startAngle * (3.141592653589793 / 180),
          child: CircularProgressIndicator(
            value: sweepAngle / 360,
            backgroundColor: Colors.transparent,
            color: _categoryColors[category] ?? Colors.grey,
            strokeWidth: 150,
          ),
        ),
      );

      startAngle += sweepAngle;
    }

    return segments;
  }
}