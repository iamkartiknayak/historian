import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/custom_tab_bar.dart';
import '../../../common/custom_tab_item.dart';
import '../providers/emoji_provider.dart';
import '../widgets/build_emojis.dart';
import '../widgets/build_recent_emojis.dart';

class EmojiPage extends StatelessWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('EmojiPage build is called');
    final emojiProvider = context.read<EmojiProvider>();
    emojiProvider.resetEmojiTabbar();
    final showRecent = context.select((EmojiProvider p) => p.showRecent);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: CustomTabBar(
              onTap: emojiProvider.updateTabIndex,
              tabController: emojiProvider.tabController,
              tabs: const [
                CustomTabItem(iconPath: 'assets/svgs/search.svg'),
                CustomTabItem(iconPath: 'assets/svgs/recent.svg'),
                CustomTabItem(iconPath: 'assets/svgs/emoji_outlined.svg'),
                CustomTabItem(iconPath: 'assets/svgs/animals_nature.svg'),
                CustomTabItem(iconPath: 'assets/svgs/food_drink.svg'),
                CustomTabItem(iconPath: 'assets/svgs/activity.svg'),
                CustomTabItem(iconPath: 'assets/svgs/travel_places.svg'),
                CustomTabItem(iconPath: 'assets/svgs/objects.svg'),
                CustomTabItem(iconPath: 'assets/svgs/symbols.svg'),
                CustomTabItem(iconPath: 'assets/svgs/flags.svg'),
              ]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: showRecent ? const BuildRecentEmojis() : const BuildEmojis(),
      ),
    );
  }
}
