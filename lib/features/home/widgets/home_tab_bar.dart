import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import './home_tab_item.dart';

class HomeTabBar extends StatelessWidget {
  const HomeTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeTabBar build is called');
    final homeProvider = context.read<HomeProvider>();
    final homeTabIndex = context.select((HomeProvider p) => p.currentTabIndex);

    return TabBar(
      onTap: homeProvider.updateTabIndex,
      controller: homeProvider.tabController,
      tabs: [
        HomeTabItem(
          iconPath: 'assets/svgs/clipboard',
          isActive: homeTabIndex == 0,
        ),
        HomeTabItem(
          iconPath: 'assets/svgs/emoji',
          isActive: homeTabIndex == 1,
        ),
        HomeTabItem(
          iconPath: 'assets/svgs/emoticon',
          isActive: homeTabIndex == 2,
        ),
      ],
    );
  }
}
