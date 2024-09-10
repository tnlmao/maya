import 'package:flutter/material.dart';

class RecipeViewer extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const RecipeViewer({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    final recipeModel = recipeData['model'];
    final title = recipeModel['title'];
    final ingredients = recipeModel['ingredients'] as List<dynamic>;
    final instructions = recipeModel['instructions'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe"),
        //backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTitle(title),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Ingredients',
              icon: Icons.kitchen,
              items: ingredients,
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Instructions',
              icon: Icons.menu_book,
              items: instructions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 252, 109, 140),Color.fromARGB(255, 221, 171, 182)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Color.fromARGB(255, 252, 109, 140),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
