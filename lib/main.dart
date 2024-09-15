import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './features/clipboard/providers/clipboard_provider.dart';
import './features/emoji/providers/emoji_provider.dart';
import './features/emoticon/providers/emoticon_provider.dart';
import './features/home/pages/home_page.dart';
import './features/home/providers/home_provider.dart';
import './features/settings/providers/settings_provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ClipboardProvider()),
        ChangeNotifierProvider(create: (_) => EmojiProvider()),
        ChangeNotifierProvider(create: (_) => EmoticonProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const Historian(),
    ));

class Historian extends StatefulWidget {
  const Historian({super.key});

  @override
  State<Historian> createState() => _HistorianState();
}

class _HistorianState extends State<Historian> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    context.read<HomeProvider>().initControllers(this);
    context.read<ClipboardProvider>().initControllers();
    context.read<EmojiProvider>().initControllers(this);
    context.read<EmoticonProvider>().initControllers(this);
    context.read<SettingsProvider>().initControllers(this);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Historian',
      home: HomePage(),
    );
  }
}
