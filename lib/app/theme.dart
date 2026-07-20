import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const seed = Color(0xFF006C72);

  static ThemeData material(Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: const InputDecorationTheme(filled: true),
  );

  static CupertinoThemeData cupertino(Brightness brightness) =>
      CupertinoThemeData(
        brightness: brightness,
        primaryColor: brightness == Brightness.dark
            ? const Color(0xFF5DD9E0)
            : seed,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? CupertinoColors.black
            : CupertinoColors.systemGroupedBackground,
      );
}
