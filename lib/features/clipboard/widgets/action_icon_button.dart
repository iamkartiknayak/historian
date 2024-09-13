import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionIconButton extends StatelessWidget {
  const ActionIconButton({
    super.key,
    required this.svgPath,
    required this.onTap,
    this.height,
  });

  final String svgPath;
  final VoidCallback onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        height: height ?? 20.0,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
