import 'package:flutter/material.dart';

import './accent_svg_icon.dart';

class CustomTabItem extends StatelessWidget {
  const CustomTabItem({
    super.key,
    required this.iconPath,
  });

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: AccentSvgIcon(iconPath: iconPath),
    );
  }
}
