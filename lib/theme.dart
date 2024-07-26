import 'package:flutter/material.dart';

class AppTheme {
  static late Color accentColor;
  static const fontFamily = 'Inter';
  HSLColor hslColor = HSLColor.fromColor(accentColor);

  static Color darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - 0.4).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // balance contrast if the accent color is too light
  static final lightThemeColor =
      accentColor.computeLuminance() >= 0.5 ? darken(accentColor) : accentColor;

  static Color getSelectionColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) return accentColor;
    return darken(accentColor);
  }

  static final lightTheme = ThemeData.light().copyWith(
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: lightThemeColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        color: lightThemeColor.withAlpha(255),
        fontSize: 14,
        height: 1.4,
        fontFamily: fontFamily,
      ),
      titleSmall: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
    ),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.dark(
        surface: lightThemeColor.withAlpha(48),
      ),
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        color: accentColor.withAlpha(200),
        fontSize: 14,
        height: 1.4,
        fontFamily: fontFamily,
      ),
      titleSmall: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
    ),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.dark(
        surface: accentColor.withAlpha(48),
      ),
    ),
  );
}
