import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class BorderRadiusConfigItem extends StatelessWidget {
  const BorderRadiusConfigItem({
    super.key,
    required this.label,
    required this.borderRadius,
    required this.position,
  });

  final String label;
  final double borderRadius;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        return InkWell(
          onTap: () => provider.setBorderRadiusConfig(position),
          child: Container(
            decoration: position == provider.selectedBorderRadiusConfig
                ? BoxDecoration(
                    border: Border.all(
                      color: provider.accentColor,
                      width: 1.6,
                    ),
                    borderRadius:
                        BorderRadius.circular(provider.categoryTwoRadius),
                  )
                : null,
            height: 90.0,
            width: 110.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30.0,
                  width: 56.0,
                  decoration: BoxDecoration(
                    color: provider.accentColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: 70.0,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
