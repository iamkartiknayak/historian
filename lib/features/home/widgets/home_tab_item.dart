import 'package:flutter/material.dart';

import '../../../common/accent_svg_icon.dart';

class HomeTabItem extends StatelessWidget {
  const HomeTabItem({
    super.key,
    required this.iconPath,
    required this.isActive,
  });

  final String iconPath;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final icon = isActive ? '${iconPath}_filled' : '${iconPath}_outlined';

    return Tab(
      icon: AccentSvgIcon(
        iconPath: '$icon.svg',
        svgHeight: 24.0,
      ),
    );
  }
}
