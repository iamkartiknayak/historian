import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.onTap,
    required this.tabController,
    required this.tabs,
  });

  final Function(int) onTap;
  final TabController tabController;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    debugPrint('CustomTabBar build is called');

    return TabBar(
      onTap: onTap,
      controller: tabController,
      indicatorColor: Colors.teal,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: tabs,
    );
  }
}
