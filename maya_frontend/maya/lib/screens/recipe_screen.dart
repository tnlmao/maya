import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maya/screens/recipe_viewer.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  String? _dietaryPreference;
  String? _cuisine;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Ingredient',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addIngredient,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _ingredients
                      .map((ingredient) => Chip(
                            label: Text(ingredient),
                            onDeleted: () => _removeIngredient(ingredient),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Dietary Preference'),
                  value: _dietaryPreference,
                  items: ['Veg', 'Non-Veg', 'Vegan']
                      .map((preference) => DropdownMenuItem(
                            value: preference,
                            child: Text(preference),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _dietaryPreference = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Cuisine'),
                  value: _cuisine,
                  items: ['Indian', 'Thai', 'Italian', 'Chinese']
                      .map((cuisine) => DropdownMenuItem(
                            value: cuisine,
                            child: Text(cuisine),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _cuisine = value;
                    });
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRecipe,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text;
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
      });
      _ingredientController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  Future<void> _submitRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/getrecipe');
    final body = jsonEncode({
      'ingredients': _ingredients,
      'dietaryPreference': _dietaryPreference,
      'cuisine': _cuisine,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RecipeViewer(recipeData: data),
          ),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit recipe.')),
        );
      }
    } catch (e) {
      print('Error submitting recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting recipe: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
