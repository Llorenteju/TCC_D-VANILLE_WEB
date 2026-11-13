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

  // Modo escuro: mantidas as cores utilizadas no site público.
  static const darkCream = Color(0xFF241F1B);
  static const darkCream2 = Color(0xFF332B26);
  static const darkSurface = Color(0xFF3A322C);
  static const darkInk = Color(0xFFFFF4E8);

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

/// Paleta adaptativa para o painel administrativo.
///
/// Use AdminColors nas páginas administrativas em vez de cores claras fixas.
/// Assim, o menu, os cards, as tabelas e os títulos ficam legíveis em ambos
/// os temas, sem alterar as cores do site público.
class AdminColors {
  static bool escuro(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color fundo(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkCream : DVanilleColors.cream;

  static Color menu(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkCream2 : DVanilleColors.white;

  static Color card(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkSurface : DVanilleColors.white;

  static Color cardAlternativo(BuildContext context) =>
      escuro(context) ? const Color(0xFF433832) : DVanilleColors.cream2;

  static Color titulo(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkInk : DVanilleColors.darkTaupe;

  static Color texto(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkInk : DVanilleColors.ink;

  static Color textoSecundario(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkTextSecondary : DVanilleColors.taupe;

  static Color destaque(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkRose : DVanilleColors.rose;

  static Color fundoSelecionado(BuildContext context) =>
      escuro(context) ? const Color(0xFF543E3B) : DVanilleColors.blush2;

  static Color borda(BuildContext context) =>
      escuro(context) ? DVanilleColors.darkBorder : DVanilleColors.line;

  static Color sair(BuildContext context) =>
      escuro(context) ? const Color(0xFFF1B0A9) : const Color(0xFFB5473F);
}

/// Cores de fundo e texto dos selos de status.
///
/// As chamadas antigas `StatusColors.fundo(status)` seguem funcionando no
/// modo claro. Para componentes administrativos, passe `isDark: true` quando
/// o tema estiver escuro ou use os atalhos `fundoNoTema`/`textoNoTema`.
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
    'utilizado': [Color(0xFFE5E0DA), Color(0xFF6B5D4F)],
    'expirado': [Color(0xFFFFEDD5), Color(0xFF9A6A12)],
    'cancelado': [Color(0xFFF6D9D6), Color(0xFFB5473F)],
    'agendada': [Color(0xFFDCEBF7), Color(0xFF2F6A99)],
    'ativa': [Color(0xFFE4EEE0), Color(0xFF3D6B3A)],
    'encerrada': [Color(0xFFE5E0DA), Color(0xFF6B5D4F)],
  };

  static const Map<String, List<Color>> _mapEscuro = {
    'recebido': [Color(0xFF4A3A2B), Color(0xFFF4CB91)],
    'pagamento': [Color(0xFF2C4352), Color(0xFFBFDEF4)],
    'em preparação': [Color(0xFF2C4352), Color(0xFFBFDEF4)],
    'pronto': [Color(0xFF2B4736), Color(0xFFB5DEBD)],
    'finalizado': [Color(0xFF45403A), Color(0xFFE2D7CA)],
    'solicitada': [Color(0xFF4A3A2B), Color(0xFFF4CB91)],
    'confirmada': [Color(0xFF2B4736), Color(0xFFB5DEBD)],
    'cancelada': [Color(0xFF502F2E), Color(0xFFF2B3AD)],
    'finalizada': [Color(0xFF45403A), Color(0xFFE2D7CA)],
    'ativo': [Color(0xFF2B4736), Color(0xFFB5DEBD)],
    'utilizado': [Color(0xFF45403A), Color(0xFFE2D7CA)],
    'expirado': [Color(0xFF4A3A2B), Color(0xFFF4CB91)],
    'cancelado': [Color(0xFF502F2E), Color(0xFFF2B3AD)],
    'agendada': [Color(0xFF2C4352), Color(0xFFBFDEF4)],
    'ativa': [Color(0xFF2B4736), Color(0xFFB5DEBD)],
    'encerrada': [Color(0xFF45403A), Color(0xFFE2D7CA)],
  };

  static List<Color> _cores(String status, bool isDark) {
    final mapa = isDark ? _mapEscuro : _map;
    return mapa[status.toLowerCase()] ?? mapa['recebido']!;
  }

  static Color fundo(String status, {bool isDark = false}) =>
      _cores(status, isDark)[0];

  static Color texto(String status, {bool isDark = false}) =>
      _cores(status, isDark)[1];

  static Color fundoNoTema(BuildContext context, String status) =>
      fundo(status, isDark: Theme.of(context).brightness == Brightness.dark);

  static Color textoNoTema(BuildContext context, String status) =>
      texto(status, isDark: Theme.of(context).brightness == Brightness.dark);
}

class AppTheme {
  /// Fonte display dos títulos.
  static const List<String> displayFallback = [
    'Georgia',
    'Times New Roman',
    'serif',
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

    final tipografia = Typography.material2021(
      platform: TargetPlatform.android,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? DVanilleColors.darkRose : DVanilleColors.taupe,
        brightness: brightness,
        surface: surface,
        primary: buttonBackground,
        onPrimary: buttonForeground,
        secondary: isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
        onSecondary: DVanilleColors.ink,
        onSurface: onSurface,
      ),
      cardColor: surface,
      canvasColor: scaffold,
      dividerColor: borderColor,
      iconTheme: IconThemeData(
        color: isDark
            ? DVanilleColors.darkTextSecondary
            : DVanilleColors.darkTaupe,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
        ),
        dataRowColor: WidgetStatePropertyAll(surface),
        headingTextStyle: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        dataTextStyle: TextStyle(
          color: onSurface,
          fontSize: 13.5,
        ),
        dividerThickness: 0.7,
      ),
      listTileTheme: ListTileThemeData(
        textColor: onSurface,
        iconColor: isDark ? DVanilleColors.darkRose : DVanilleColors.darkTaupe,
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? DVanilleColors.darkSurface : DVanilleColors.cream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
            width: 2,
          ),
        ),
      ),
      textTheme: (isDark ? tipografia.white : tipografia.black)
          .apply(bodyColor: onSurface, displayColor: onSurface)
          .copyWith(
            bodyMedium: TextStyle(color: onSurface),
            bodySmall: TextStyle(color: textSecondary),
            labelMedium: TextStyle(color: textSecondary),
          ),
    );
  }
}
