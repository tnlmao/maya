import 'package:flutter/material.dart';

class GymTrackingScreen extends StatelessWidget {
  const GymTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracking'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text('Gym Tracking Content'),
      ),
    );
  }
}
