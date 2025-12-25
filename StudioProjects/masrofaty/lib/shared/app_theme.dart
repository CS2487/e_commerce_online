import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF1C3941);
  static const Color whiteColor = Color(0xFFFFFFFF);  static const Color redColor = Color(0xFFE81515);


  // ================== LIGHT & DARK THEME ==================
  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // ================== TextTheme ==================
    final textTheme = TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface),
      headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface),
      titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface),
      titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface),
      labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary),
      labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary),
      labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: seedColor,

      // ================== AppBar ==================
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,

        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineMedium,
      ),

      // ================== Buttons ==================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelMedium,
        ),
      ),

      // ================== Cards ==================
      cardTheme: CardTheme(
        elevation: 1,
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
//=================== TextFields ==================
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ================== Selection ==================
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: seedColor,
        selectionColor: seedColor.withOpacity(0.3),
        selectionHandleColor: seedColor,
      ),

      // ================== FloatingActionButton ==================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      // ================== BottomNavigationBar ==================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // ================== SnackBar ==================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.green,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
