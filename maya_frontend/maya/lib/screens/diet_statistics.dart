import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:maya/main.dart';

class DietStatisticsScreen extends StatefulWidget {
  const DietStatisticsScreen({Key? key}) : super(key: key);

  @override
  _DietStatisticsScreenState createState() => _DietStatisticsScreenState();
}

class _DietStatisticsScreenState extends State<DietStatisticsScreen> {
  DateTime? _selectedDate;
  Map<String, dynamic>? _dietDetails;
  bool _loading = false;
  //final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Statistics'),
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dietDetails == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Select a date to view diet statistics'),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Change Date'),
                    ),
                    _buildDietCard('Breakfast', _dietDetails!['breakfast']),
                    _buildDietCard('Brunch', _dietDetails!['brunch']),
                    _buildDietCard('Lunch', _dietDetails!['lunch']),
                    _buildDietCard('Snack', _dietDetails!['snack']),
                    _buildDietCard('Dinner', _dietDetails!['dinner']),
                    _buildDietCard('Supper', _dietDetails!['supper']),
                  ],
                ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loading = true;
      });
      await _fetchDietDetails();
    }
  }

  Future<void> _fetchDietDetails() async {
    if (_selectedDate == null) return;

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final url = Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/getdietdetails');

    final Map<String, dynamic> requestBody = {
      'uid': user?.uid, 
      'date': formattedDate,
    };
    print(jsonEncode(requestBody));
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    final Map<String, dynamic> responseBody = json.decode(response.body);
    print(jsonEncode(response.body));
    if (response.statusCode == 200) {
      setState(() {
        _dietDetails = responseBody['model'];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch diet details')),
      );
    }
  }

 Widget _buildDietCard(String title, Map<String, dynamic>? details) {
  if (details == null) {
    // Handle case where details are null
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text('No details available for $title'),
      ),
    );
  }

  // Ensure all required fields are present and valid
  final int calories = details['calories'] ?? 0;
  final int protein = details['protein'] ?? 0;
  final int carbs = details['carbs'] ?? 0;
  final int fats = details['fats'] ?? 0;
  final int fibre = details['fibre'] ?? 0;
  final int minerals = details['minerals'] ?? 0;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('Calories: $calories'),
          Text('Protein: $protein g'),
          Text('Carbs: $carbs g'),
          Text('Fats: $fats g'),
          Text('Fibre: $fibre g'),
          Text('Minerals: $minerals g'),
        ],
      ),
    ),
  );
}

}
