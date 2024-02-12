import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import './theme.dart';
import './features/settings/pages/settings_pag.dart';
import './features/clipboard/pages/clipboard_page.dart';
import './features/clipboard/provider/clipboard_provider.dart';
import './features/settings/provider/setting_page_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WindowManager.instance.setTitle('Historian');
  WindowManager.instance.setMinimumSize(const Size(400, 600));
  WindowManager.instance.setMaximumSize(const Size(400, 600));
  // WindowManager.instance.setSkipTaskbar(true); // breaks app in windows
  WindowManager.instance.focus();
  WindowManager.instance.setAlwaysOnTop(true);
  runApp(const Historian());
}

class Historian extends StatelessWidget {
  const Historian({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClipboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsPageProvider()),
      ],
      child: MaterialApp(
        title: 'Historian',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routes: {
          '/': (_) => const ClipboardPage(),
          SettingsPage.pageRoute: (_) => const SettingsPage(),
        },
      ),
    );
  }
}
