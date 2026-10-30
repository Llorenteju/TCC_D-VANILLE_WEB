import 'package:flutter/material.dart';

/// Paleta de cores da D'Vanille.
class DVanilleColors {
  // Modo claro
  static const cream = Color(0xFFFFF4E8);
  static const cream2 = Color(0xFFFFEEDD);
  static const taupe = Color(0xFF9C8A73);
  static const darkTaupe = Color(0xFF7C6C58);
  static const blush = Color(0xFFEFCDCC);
  static const blush2 = Color(0xFFF6DEDC);
  static const rose = Color(0xFFC98F8C);
  static const ink = Color(0xFF2B2420);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0x479C8A73);

  // Modo escuro - paleta revisada
  static const darkCream = Color(0xFF241F1B);
  static const darkCream2 = Color(0xFF332B26);
  static const darkSurface = Color(0xFF3A322C);
  static const darkInk = Color(0xFFFFF4E8);

  // Textos e detalhes do modo escuro
  static const darkTextSecondary = Color(0xFFD9C6AF);
  static const darkTextMuted = Color(0xFFC4AD93);
  static const darkRose = Color(0xFFE6A9A5);
  static const darkButton = Color(0xFFB99F82);
  static const darkBorder = Color(0xFF55483D);

  // Badges de restrição
  static const badgeGluten = Color(0xFFF3E7D3);
  static const badgeLactose = Color(0xFFE4EEE0);
  static const badgeVegan = Color(0xFFDCEEDB);
  static const badgeVeg = Color(0xFFE8F0DE);
  static const badgeSugar = Color(0xFFF6E4D9);
}

/// Cores de fundo/texto dos selos de status.
class StatusColors {
  static const Map<String, List<Color>> _map = {
    'recebido': [Color(0xFFFDE9D0), Color(0xFF9A6A12)],
    'pagamento': [Color(0xFFDCEBF7), Color(0xFF2F6A99)],
    'em preparação': [Color(0xFFDCEBF7), Color(0xFF2F6A99)],
    'pronto': [Color(0xFFE4EEE0), Color(0xFF3D6B3A)],
    'finalizado': [Color(0xFFE5E0DA), Color(0xFF6B5D4F)],
    'solicitada': [Color(0xFFFDE9D0), Color(0xFF9A6A12)],
    'confirmada': [Color(0xFFE4EEE0), Color(0xFF3D6B3A)],
    'cancelada': [Color(0xFFF6D9D6), Color(0xFFB5473F)],
    'finalizada': [Color(0xFFE5E0DA), Color(0xFF6B5D4F)],
    'ativo': [Color(0xFFE4EEE0), Color(0xFF3D6B3A)],
  };

  static Color fundo(String status) => (_map[status] ?? _map['recebido']!)[0];

  static Color texto(String status) => (_map[status] ?? _map['recebido']!)[1];
}

class AppTheme {
  /// Fonte display dos títulos.
  static const List<String> displayFallback = [
    'Georgia',
    'Times New Roman',
    'serif'
  ];

  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) =>
      TextStyle(
        fontFamilyFallback: displayFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: .2,
      );

  static ThemeData get light => _base(
        brightness: Brightness.light,
        scaffold: DVanilleColors.cream,
        surface: DVanilleColors.white,
        onSurface: DVanilleColors.ink,
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        scaffold: DVanilleColors.darkCream,
        surface: DVanilleColors.darkSurface,
        onSurface: DVanilleColors.darkInk,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;

    final textSecondary =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    final buttonBackground =
        isDark ? DVanilleColors.darkButton : DVanilleColors.taupe;

    final buttonForeground =
        isDark ? DVanilleColors.darkCream : DVanilleColors.white;

    final borderColor =
        isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? DVanilleColors.darkRose : DVanilleColors.taupe,
        brightness: brightness,
        surface: surface,
        primary: isDark ? DVanilleColors.darkButton : DVanilleColors.taupe,
        onPrimary: isDark ? DVanilleColors.darkCream : DVanilleColors.white,
        secondary: isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
        onSecondary: DVanilleColors.ink,
        onSurface: onSurface,
      ),
      cardColor: surface,
      dividerColor: borderColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor:
            isDark ? DVanilleColors.darkInk : DVanilleColors.darkTaupe,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? DVanilleColors.darkSurface : DVanilleColors.darkTaupe,
        contentTextStyle: TextStyle(
          color: isDark ? DVanilleColors.darkInk : DVanilleColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: buttonBackground,
          foregroundColor: buttonForeground,
          disabledBackgroundColor:
              isDark ? DVanilleColors.darkSurface : DVanilleColors.cream2,
          disabledForegroundColor: textSecondary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? DVanilleColors.darkInk : DVanilleColors.darkTaupe,
          side: BorderSide(
            color: isDark ? DVanilleColors.darkTextMuted : DVanilleColors.taupe,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? DVanilleColors.darkSurface : DVanilleColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: isDark
              ? DVanilleColors.darkTextSecondary
              : DVanilleColors.darkTaupe,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: isDark ? DVanilleColors.darkTextMuted : DVanilleColors.taupe,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
            width: 2,
          ),
        ),
      ),
      textTheme: Typography.material2021(
        platform: TargetPlatform.android,
      )
          .black
          .apply(
            bodyColor: onSurface,
            displayColor: onSurface,
          )
          .copyWith(
            bodyMedium: TextStyle(color: onSurface),
            bodySmall: TextStyle(color: textSecondary),
            labelMedium: TextStyle(color: textSecondary),
          ),
    );
  }
}
