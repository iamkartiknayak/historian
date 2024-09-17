import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/settings/providers/settings_provider.dart';

class AppTheme {
  static void setAccentPallete(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    Future(() {
      if (context.mounted) {
        context.read<SettingsProvider>().setAccentPallete(isLightTheme);
      }
    });
  }

  static ThemeData lightTheme(
      Color accentColor, (double, double) borderRadius) {
    return ThemeData.light().copyWith(
      primaryColor: accentColor,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: accentColor.withOpacity(0.4),
        selectionHandleColor: accentColor,
        cursorColor: accentColor,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: accentColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: accentColor,
      ),
      extensions: <ThemeExtension<dynamic>>[
        BorderRadiusTheme(
          categoryOneRadius: borderRadius.$1,
          categoryTwoRadius: borderRadius.$2,
        ),
      ],
    );
  }

  static ThemeData darkTheme(Color accentColor, (double, double) borderRadius) {
    return ThemeData.dark().copyWith(
      primaryColor: accentColor,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: accentColor.withOpacity(0.4),
        selectionHandleColor: accentColor,
        cursorColor: accentColor,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: accentColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: accentColor,
      ),
      extensions: <ThemeExtension<dynamic>>[
        BorderRadiusTheme(
          categoryOneRadius: borderRadius.$1,
          categoryTwoRadius: borderRadius.$2,
        ),
      ],
    );
  }
}

class BorderRadiusTheme extends ThemeExtension<BorderRadiusTheme> {
  final double categoryOneRadius;
  final double categoryTwoRadius;

  BorderRadiusTheme({
    required this.categoryOneRadius,
    required this.categoryTwoRadius,
  });

  @override
  BorderRadiusTheme copyWith({
    double? categoryOneRadius,
    double? categoryTwoRadius,
  }) {
    return BorderRadiusTheme(
      categoryOneRadius: categoryOneRadius ?? this.categoryOneRadius,
      categoryTwoRadius: categoryTwoRadius ?? this.categoryTwoRadius,
    );
  }

  @override
  BorderRadiusTheme lerp(ThemeExtension<BorderRadiusTheme>? other, double t) {
    if (other is! BorderRadiusTheme) {
      return this;
    }
    return BorderRadiusTheme(
      categoryOneRadius: categoryOneRadius,
      categoryTwoRadius: categoryTwoRadius,
    );
  }
}
