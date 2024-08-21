import 'package:flutter/material.dart';

void main() => runApp(const Historian());

class Historian extends StatelessWidget {
  const Historian({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Historian',
      home: Scaffold(
        body: Center(
          child: Text(
            'Historian',
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}
