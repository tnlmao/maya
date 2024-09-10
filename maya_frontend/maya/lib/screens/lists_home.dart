import 'package:flutter/material.dart';
import 'package:maya/screens/news_page.dart';
import 'package:maya/screens/recipe_screen.dart';
import 'package:maya/screens/todo_list.dart';
import 'gym_tracking.dart';
import 'kitchen_lists.dart';

class ListsHome extends StatelessWidget {
  const ListsHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lists'),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildCard(
            icon: Icons.calculate,
            title: 'To-Do List',
            subtitle: 'Manage your tasks here.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoListScreen()),
              );
            },
          ),
          buildCard(
            icon: Icons.bar_chart,
            title: 'Kitchen Groceries',
            subtitle: 'Manage your kitchen groceries here.',
            onTap: () async{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KitchenListsScreen()),
              );
            },
          ),
          buildCard(
            icon: Icons.fitness_center,
            title: 'Daily Needs',
            subtitle: 'Manage your daily needs here.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsPage()),
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
