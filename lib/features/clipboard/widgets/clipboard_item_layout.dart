import 'package:flutter/material.dart';

import '../../../app_theme.dart';

class ClipboardItemLayout extends StatelessWidget {
  const ClipboardItemLayout({
    super.key,
    required this.isActive,
    required this.child,
    required this.onTap,
  });

  final bool isActive;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<BorderRadiusTheme>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 120.0,
          maxHeight: 120.0,
          minWidth: double.infinity,
        ),
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(borderRadius!.categoryTwoRadius),
        ),
        child: child,
      ),
    );
  }
}
