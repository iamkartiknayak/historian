import 'package:flutter/material.dart';

import './features/home/pages/home_page.dart';

void main() => runApp(const Historian());

class Historian extends StatelessWidget {
  const Historian({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Historian',
      home: HomePage(),
    );
  }
}
