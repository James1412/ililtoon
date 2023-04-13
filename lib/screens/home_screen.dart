import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todays Toon",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
    );
  }
}
