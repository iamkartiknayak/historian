import 'package:flutter/material.dart';

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
            color: isActive ? Colors.teal : Colors.grey,
            width: isActive ? 1.5 : 0.8,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: child,
      ),
    );
  }
}
