import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/keyboard_services.dart';
import '../../clipboard/pages/clipboard_page.dart';
import '../../emoji/pages/emoji_page.dart';
import '../../emoticon/pages/emoticon_page.dart';
import '../providers/home_provider.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/settings_button.dart';

final homePageKey = GlobalKey<HomePageState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int homeTabIndex = 0;

  @override
  void dispose() {
    KeyboardService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage build is called');
    KeyboardService.initKeyboardListener(context);
    homeTabIndex = context.select((HomeProvider p) => p.currentTabIndex);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Row(
            children: [
              Expanded(child: HomeTabBar()),
              SizedBox(width: 40.0),
              SettingsButton(),
              SizedBox(width: 12.0),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: context.read<HomeProvider>().tabController,
        children: const [
          ClipboardPage(),
          EmojiPage(),
          EmoticonPage(),
        ],
      ),
    );
  }
}
