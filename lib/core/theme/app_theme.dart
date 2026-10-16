import 'package:flutter/material.dart';

/// SolarShare BD color palette.
/// Fresh community-solar identity: deep teal green + solar amber accents.
class AppColors {
  static const Color teal900 = Color(0xFF0B5E4A);
  static const Color teal700 = Color(0xFF12795F);
  static const Color teal500 = Color(0xFF1FA37F);
  static const Color teal100 = Color(0xFFDDF2EA);
  static const Color teal50 = Color(0xFFEEF8F4);

  static const Color amber500 = Color(0xFFF5A623);
  static const Color amber100 = Color(0xFFFDF0D8);

  static const Color orange500 = Color(0xFFF4762B);

  static const Color ink = Color(0xFF16232E);
  static const Color inkSoft = Color(0xFF5B6B76);
  static const Color surface = Colors.white;
  static const Color bg = Color(0xFFF4FAF7);
  static const Color danger = Color(0xFFD64545);
  static const Color success = Color(0xFF1FA37F);
}

class AppTheme {
  static ThemeData light() {
    const base = ColorScheme.light(
      primary: AppColors.teal700,
      secondary: AppColors.amber500,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'HindSiliguri',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.teal50,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.teal900,
        titleTextStyle: TextStyle(
          fontFamily: 'HindSiliguri',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.teal900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal700,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'HindSiliguri',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.teal100,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'HindSiliguri',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.teal900,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDED9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDED9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal500, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.teal900,
        contentTextStyle: const TextStyle(
          fontFamily: 'HindSiliguri',
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
