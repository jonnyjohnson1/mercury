import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF343232),
      body: Center(
        child: Text(
          'Welcome to Mercury',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
