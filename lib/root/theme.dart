import 'package:flutter/material.dart';
import 'pallet.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppPalette.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'serif',
        color: AppPalette.text,
      ),
    ),
  );
}