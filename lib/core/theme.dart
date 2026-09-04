import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006161),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF0E7C7B),
    onPrimaryContainer: Color(0xFFC3FFFD),
    secondary: Color(0xFF516161),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD4E6E5),
    onSecondaryContainer: Color(0xFF576867),
    tertiary: Color(0xFF854524),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFA35D39),
    onTertiaryContainer: Color(0xFFFFF1EB),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF0B1C30),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF4FF),
    surfaceContainer: Color(0xFFE5EEFF),
    surfaceContainerHigh: Color(0xFFDCE9FF),
    surfaceContainerHighest: Color(0xFFD3E4FE),
    surfaceDim: Color(0xFFCBDBF5),
    surfaceBright: Color(0xFFF8F9FF),
    onSurfaceVariant: Color(0xFF3E4948),
    outline: Color(0xFF6E7979),
    outlineVariant: Color(0xFFBDC9C8),
    inverseSurface: Color(0xFF213145),
    onInverseSurface: Color(0xFFEAF1FF),
    inversePrimary: Color(0xFF7CD5D3),
    surfaceTint: Color(0xFF006A69),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,
  );
}
