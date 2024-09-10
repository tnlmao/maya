import 'package:flutter/material.dart';

class KitchenListsScreen extends StatelessWidget {
  const KitchenListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Lists'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text('Kitchen Lists Content'),
      ),
    );
  }
}
