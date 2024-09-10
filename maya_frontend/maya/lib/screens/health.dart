import 'package:flutter/material.dart';
import 'package:maya/screens/recipe_screen.dart';
import 'calorie_calculator.dart';
import 'diet_statistics.dart';
import 'gym_tracking.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Health'),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildCard(
            icon: Icons.calculate,
            title: 'Calorie Calculator',
            subtitle: 'Calculate your daily calorie intake.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalorieCalculatorScreen()),
              );
            },
          ),
          buildCard(
            icon: Icons.bar_chart,
            title: 'Diet Statistics',
            subtitle: 'View your diet statistics.',
            onTap: () async{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DietStatisticsScreen()),
              );
            },
          ),
          buildCard(
            icon: Icons.fitness_center,
            title: 'Gym Tracking',
            subtitle: 'Track your gym workouts and progress.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GymTrackingScreen()),
              );
            },
          ),
          buildCard(
            icon: Icons.fastfood,
            title: 'Recipes',
            subtitle: 'Explore recipes of your liking.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
