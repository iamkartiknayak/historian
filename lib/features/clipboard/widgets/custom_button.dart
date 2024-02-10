import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.label,
    this.icon,
    this.onTap,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 28,
          maxHeight: 28,
          minWidth: 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme!.background,
          borderRadius: BorderRadius.circular(label != null ? 4 : 4),
        ),
        padding: label != null
            ? const EdgeInsets.symmetric(horizontal: 10)
            : const EdgeInsets.all(4),
        child: label != null
            ? Center(
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              )
            : Icon(
                icon,
                size: 16,
              ),
      ),
    );
  }
}
