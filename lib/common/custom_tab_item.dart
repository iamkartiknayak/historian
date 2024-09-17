import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTabItem extends StatelessWidget {
  const CustomTabItem({
    super.key,
    required this.iconPath,
  });

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          Theme.of(context).primaryColor,
          BlendMode.srcIn,
        ),
        fit: BoxFit.fitHeight,
        height: 20,
      ),
    );
  }
}
