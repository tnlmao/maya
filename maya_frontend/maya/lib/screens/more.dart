import 'package:flutter/material.dart';
import 'package:maya/services/auth_service.dart';
import 'package:maya/services/auth_service.dart';

class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('More'),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        children: <Widget>[
          // Add other list items here

          // Logout option
          ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text('Logout'),
            onTap: () async {
              await _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
