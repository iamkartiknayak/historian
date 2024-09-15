import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/custom_tab_bar.dart';
import '../../../common/custom_tab_item.dart';
import '../providers/emoticon_provider.dart';
import '../widgets/build_emoticons.dart';
import '../widgets/build_recent_emoticons.dart';

class EmoticonPage extends StatelessWidget {
  const EmoticonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emoticonProvider = context.read<EmoticonProvider>();
    final (showRecent) = context.select((EmoticonProvider p) => p.showRecent);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: CustomTabBar(
              onTap: emoticonProvider.updateTabIndex,
              tabController: emoticonProvider.tabController,
              tabs: const [
                CustomTabItem(iconPath: 'assets/svgs/search.svg'),
                CustomTabItem(iconPath: 'assets/svgs/recent.svg'),
                CustomTabItem(iconPath: 'assets/svgs/list.svg'),
              ]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child:
            showRecent ? const BuildRecentEmoticons() : const BuildEmoticons(),
      ),
    );
  }
}
