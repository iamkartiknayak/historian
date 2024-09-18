import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class AccentColorPallete extends StatelessWidget {
  const AccentColorPallete({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AccentColorPallete build is called');
    final settingsProvider = context.read<SettingsProvider>();
    final borderColor = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        itemCount: settingsProvider.accentColors.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => settingsProvider.setAccentColor(index),
            child: Selector<SettingsProvider, (int, double)>(
              selector: (p0, p1) => (
                p1.accentColorIndex,
                p1.categoryOneRadius,
              ),
              builder: (context, provider, _) {
                debugPrint('AccentColorPallete builder is called');

                return Container(
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: settingsProvider.accentColors[index],
                    border: provider.$1 == index
                        ? Border.all(
                            color: borderColor,
                            width: 2.5,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(provider.$2),
                  ),
                );
              },
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 10.0);
        },
      ),
    );
  }
}
