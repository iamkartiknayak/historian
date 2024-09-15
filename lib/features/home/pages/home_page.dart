import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clipboard/pages/clipboard_page.dart';
import '../../emoji/pages/emoji_page.dart';
import '../../emoticon/pages/emoticon_page.dart';
import '../providers/home_provider.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/settings_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage build is called');

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
