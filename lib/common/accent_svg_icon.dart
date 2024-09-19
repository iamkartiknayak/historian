import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AccentSvgIcon extends StatelessWidget {
  const AccentSvgIcon({
    super.key,
    required this.iconPath,
    this.svgHeight = 20.0,
  });

  final String iconPath;
  final double svgHeight;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      colorFilter: ColorFilter.mode(
        Theme.of(context).primaryColor,
        BlendMode.srcIn,
      ),
      fit: BoxFit.fitHeight,
      height: svgHeight,
    );
  }
}
