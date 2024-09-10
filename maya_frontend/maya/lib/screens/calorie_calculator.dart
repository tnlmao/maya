import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:maya/screens/diet_statistics.dart';
import 'package:maya/services/auth_service.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MaterialApp(
    home: CalorieCalculatorScreen(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Lexend',
    ),
  ));
}

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalorieCalculatorScreenState createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final List<Ingredient> _ingredients = [];
  List<Ingredient> _allIngredients = [];
  final _ingredientController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadIngredientsFromCSV();
  }

  Future<void> _loadIngredientsFromCSV() async {
    try {
      final String fileName = 'ingredients.csv';
      final String pathToFile = path.join('lib', 'utils', fileName);

      String csvString = await rootBundle.loadString(pathToFile);
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

      int ingredientNameIndex = csvTable[0].indexOf('Ingredients');
      if (ingredientNameIndex == -1) {
        print('Column "Ingredients" not found in CSV file');
        return;
      }

      setState(() {
        _allIngredients = csvTable.skip(1).map((row) {
          return Ingredient(
            name: row[ingredientNameIndex].toString(),
            amount: 0,
            code: row[ingredientNameIndex - 1].toString(),
          );
        }).toList();
      });
    } catch (e) {
      print('Error reading CSV file: $e');
    }
  }

  void _addIngredient(Ingredient ingredient) {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      setState(() {
        _ingredients.add(Ingredient(name: ingredient.name, amount: amount, code: ingredient.code));
      });
      _ingredientController.clear();
      _amountController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _removeIngredient(Ingredient ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

Future<DietSummary> _calculateDietSummary() async {
  return Future.delayed(const Duration(seconds: 2), () async {
    List<Map<String, dynamic>> ingredientsData = _ingredients.map((ingredient) {
      return {
        'name': ingredient.name,
        'amount': ingredient.amount,
        'code': ingredient.code,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/calorie"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(ingredientsData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('model')) {
          Map<String, dynamic> model = responseBody['model'];
          DietSummary dietSummary = DietSummary.fromJson(model);
          dietSummary.ingredients = _ingredients.map((ingredient) => ingredient.name).toList();
          return dietSummary;
        }
      } else {
        print('Failed to fetch data. Error ${response.statusCode}');
        return DietSummary(calories: 0, protein: 0, carbs: 0, fats: 0, minerals: 0, fibre: 0);
      }
    } catch (e) {
      print('Error sending data: $e');
      // Return a default DietSummary or handle the error as needed
      return DietSummary(calories: 0, protein: 0, carbs: 0, fats: 0, minerals: 0, fibre: 0);
    }
    return DietSummary(calories: 0, protein: 0, carbs: 0, fats: 0, minerals: 0, fibre: 0);
  });
}

  Future<void> _storeDietSummary(DietSummary summary,String uid) async {
      try {
        final Map<String, dynamic> requestBody = summary.toJson();
        requestBody['uid'] = uid;
        print(jsonEncode(requestBody));
        final response = await http.post(
          Uri.parse("https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/storedietsummary"), // Replace with your actual URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            requestBody
          ),  
        );

        if (response.statusCode == 200) {
          print('Summary stored successfully');
        } else {
          print('Failed to store summary. Error ${response.statusCode}');
        }
      } catch (e) {
        print('Error storing summary: $e');
      }
    }
  void _onIngredientTextChanged(String text) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calorie Calculator',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<Ingredient>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return _allIngredients.where((ingredient) =>
                          ingredient.name.toLowerCase().contains(textEditingValue.text.toLowerCase())
                      ).toList();
                    },
                    displayStringForOption: (ingredient) => ingredient.name,
                    onSelected: (ingredient) {
                      _ingredientController.text = ingredient.name;
                      FocusScope.of(context).requestFocus(_amountFocusNode);
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      _ingredientController.addListener(() {
                        textEditingController.value = _ingredientController.value;
                      });

                      return TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                          labelText: 'Ingredient',
                          hintText: 'Enter ingredient name',
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w300
                        ),
                        focusNode: focusNode,
                        onChanged: _onIngredientTextChanged,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (grams)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    focusNode: _amountFocusNode,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w300
                    )
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: Colors.black,
                  onPressed: () {
                    final selectedIngredient = _allIngredients.firstWhere(
                      (ingredient) => ingredient.name == _ingredientController.text,
                      orElse: () => Ingredient(name: _ingredientController.text, amount: 0, code: ''),
                    );
                    _addIngredient(selectedIngredient);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.black),
                      title: Text(ingredient.name),
                      subtitle: Text('${ingredient.amount} grams'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeIngredient(ingredient),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final summary = await _calculateDietSummary();
                final bool shouldStore = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Diet Summary',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      content: Container(
                        width: double.maxFinite,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.black, // Light blue background color for the card
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummaryRow('Calories', '${summary.calories} kcal'),
                                _buildSummaryRow('Protein', '${summary.protein} g'),
                                _buildSummaryRow('Carbs', '${summary.carbs} g'),
                                _buildSummaryRow('Fats', '${summary.fats} g'),
                                _buildSummaryRow('Minerals', '${summary.minerals} g'),
                                _buildSummaryRow('Fibre', '${summary.fibre} g'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final uid = await AuthService().getCurrentUserUid();
                            if (uid != "") {
                              Navigator.of(context).pop(true);
                              Navigator.of(context).pop();
                              await _storeDietSummary(summary,uid as String);
                            } else {
                              print('User is not logged in');
                              Navigator.of(context).pop(false);
                            }
                          },
                          child: const Text('+'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                );
                // if (shouldStore) {
                //   final uid = await AuthService().getCurrentUserUid();
                //   if (uid != "") {
                //     Navigator.of(context).pop(true);
                //     await _storeDietSummary(summary,uid as String);
                //   } else {
                //     print('User is not logged in');
                //     Navigator.of(context).pop(false);
                //   }
                 
                // }
              },
              child: const Text(
                'Calculate Summary',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w300,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class Ingredient {
  final String name;
  final double amount;
  final String code;

  Ingredient({required this.name, required this.amount, required this.code});
}

class DietSummary {
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fats;
  final int? minerals;
  final int? fibre;
  List<String>? ingredients;

  DietSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.minerals,
    required this.fibre,
    this.ingredients,
  });

  factory DietSummary.fromJson(Map<String, dynamic> json) {
    List<String>? ingredientsList = [];
    if (json.containsKey('ingredients')) {
      ingredientsList = List<String>.from(json['ingredients']);
    }
    return DietSummary(
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fats: json['fats'],
      minerals: json['minerals'],
      fibre: json['fibre'],
      ingredients: ingredientsList,
    );
  }
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> formattedIngredients = [];
    if (ingredients != null) {
      formattedIngredients = ingredients!.map((ingredient) => {'name': ingredient}).toList();
    }
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'minerals': minerals,
      'fibre': fibre,
      'ingredients': formattedIngredients,
    };
  }
}
Widget _buildSummaryRow(String label, String value) {
  Color color;

  switch (label) {
    case 'Calories':
      color = Colors.white;
      break;
    case 'Protein':
      color = Colors.white;
      break;
    case 'Carbs':
      color = Colors.white;
      break;
    case 'Fats':
      color = Colors.white;
      break;
    case 'Minerals':
      color = Colors.white;
      break;
    case 'Fibre':
      color = Colors.white;
      break;
    default:
      color = Colors.white;
  }
 
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: color, // Color for the label text
            
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}