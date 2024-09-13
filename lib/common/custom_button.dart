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
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4.0),
        ),
        margin: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        child: label != null
            ? Text(
                label!,
                style: Theme.of(context).textTheme.labelMedium,
              )
            : null,
      ),
    );
  }
}
