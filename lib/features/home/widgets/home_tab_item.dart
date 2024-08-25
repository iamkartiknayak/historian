import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      icon: SvgPicture.asset(
        '$icon.svg',
        colorFilter: const ColorFilter.mode(
          Colors.teal,
          BlendMode.srcIn,
        ),
        fit: BoxFit.fitHeight,
        height: 24,
      ),
    );
  }
}
