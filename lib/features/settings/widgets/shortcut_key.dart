import 'package:flutter/material.dart';
import 'package:historian/app_theme.dart';

class ShortcutKey extends StatelessWidget {
  const ShortcutKey({
    super.key,
    required this.shortcutKey,
  });
  final String shortcutKey;

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<BorderRadiusTheme>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius!.categoryTwoRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 2.0,
      ),
      child: Text(shortcutKey),
    );
  }
}
