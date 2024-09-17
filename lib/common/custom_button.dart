import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../features/settings/providers/settings_provider.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.label,
    this.svgPath,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.margin,
    this.svgHeight = 20.0,
    this.noAccent = false,
  }) : assert(
          (label == null) != (svgPath == null),
          'Either label or svgPath must be provided, but not both.',
        );

  final String? label;
  final String? svgPath;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;
  final EdgeInsetsGeometry? margin;
  final double? svgHeight;
  final bool noAccent;

  @override
  Widget build(BuildContext context) {
    final (accentColor, borderRadius) = context.select(
      (SettingsProvider p) => (p.accentColor, p.categoryTwoRadius),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        onLongPressStart: onLongPressStart,
        onLongPressEnd: onLongPressEnd,
        child: Container(
          decoration: noAccent
              ? null
              : BoxDecoration(
                  color: accentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
          margin: margin,
          padding: label != null
              ? const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0)
              : const EdgeInsets.fromLTRB(2.5, 2.0, 2.5, 2.0),
          child: label != null
              ? Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium,
                )
              : SvgPicture.asset(
                  svgPath!,
                  height: svgHeight ?? 20.0,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }
}
