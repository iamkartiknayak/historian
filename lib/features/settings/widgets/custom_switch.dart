import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const switchWidth = 48.0;
  static const switchHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider, (Animation<double>, double, Color)>(
      selector: (_, p1) => (p1.animation, p1.categoryOneRadius, p1.accentColor),
      builder: (context, value, _) {
        return InkWell(
          onTap: onTap,
          child: AnimatedBuilder(
            animation: value.$1,
            builder: (context, child) {
              return Container(
                width: switchWidth,
                height: switchHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    value.$2,
                  ),
                  color: Color.lerp(
                    const Color(0xFF33302f),
                    value.$3,
                    value.$1.value,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: value.$1.value * (switchWidth - switchHeight),
                      child: Container(
                        width: switchWidth - 28,
                        height: switchHeight - 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1.6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            value.$2,
                          ),
                          color: const Color(0xFF141517),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
