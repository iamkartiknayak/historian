import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './features/emoji/providers/emoji_provider.dart';
import './features/home/pages/home_page.dart';
import './features/home/providers/home_provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => EmojiProvider()),
      ],
      child: const Historian(),
    ));

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
