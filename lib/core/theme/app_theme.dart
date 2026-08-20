import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores Dark Atlética & Moderna
  static const Color primary = Color(0xFF3B82F6);        // Azul eléctrico
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF10B981);      // Verde esmeralda deportivo
  static const Color background = Color(0xFF0F172A);     // Slate oscuro profundo (900)
  static const Color surface = Color(0xFF1E293B);        // Slate tarjeta (800)
  static const Color surfaceVariant = Color(0xFF334155); // Slate elevado (700)
  static const Color textPrimary = Color(0xFFF8FAFC);    // Blanco puro
  static const Color textSecondary = Color(0xFF94A3B8);  // Gris texto claro (400)
  static const Color textHint = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);          // Rojo alerta
  static const Color divider = Color(0xFF334155);        // Bordes y separadores sutiles

  // Colores temáticos de intensidad de carga (Escala 5 niveles)
  static const Color intensityMuyLigero = Color(0xFF06B6D4); // Cyan / Celeste suave
  static const Color intensityLigero = Color(0xFF10B981);    // Verde esmeralda
  static const Color intensityNormal = Color(0xFF38BDF8);    // Azul cielo
  static const Color intensityIntenso = Color(0xFFF59E0B);   // Ámbar / Naranja fuego
  static const Color intensityMuyIntenso = Color(0xFFEF4444); // Rojo potencia

  // Compatibilidad con nombres anteriores
  static const Color intensityFuerte = intensityIntenso;
  static const Color intensityMuyFuerte = intensityMuyIntenso;

  static Color getIntensityColor(String intensity, [int? index, int? total]) {
    final clean = intensity.trim().toLowerCase();
    if (clean.contains('muy ligero') || clean.contains('muy suave') || clean.contains('regenerativo')) {
      return intensityMuyLigero;
    }
    if (clean.contains('muy intenso') || clean.contains('muy fuerte') || clean.contains('máximo') || clean.contains('maximo')) {
      return intensityMuyIntenso;
    }
    if (clean.contains('ligero') || clean.contains('suave')) {
      return intensityLigero;
    }
    if (clean.contains('normal') || clean.contains('moderado') || clean.contains('medio')) {
      return intensityNormal;
    }
    if (clean.contains('intenso') || clean.contains('fuerte') || clean.contains('alto')) {
      return intensityIntenso;
    }

    // Si es un nivel personalizado y se conocen el índice y total
    if (index != null && total != null && total > 1) {
      final ratio = index / (total - 1);
      if (ratio <= 0.2) return intensityMuyLigero;
      if (ratio <= 0.4) return intensityLigero;
      if (ratio <= 0.6) return intensityNormal;
      if (ratio <= 0.8) return intensityIntenso;
      return intensityMuyIntenso;
    }

    return intensityNormal;
  }

  static int getIntensityScore(String intensity, [int? index, int? total]) {
    final clean = intensity.trim().toLowerCase();
    if (clean.contains('muy ligero') || clean.contains('muy suave') || clean.contains('regenerativo')) {
      return 20;
    }
    if (clean.contains('muy intenso') || clean.contains('muy fuerte') || clean.contains('máximo') || clean.contains('maximo')) {
      return 100;
    }
    if (clean.contains('ligero') || clean.contains('suave')) {
      return 40;
    }
    if (clean.contains('normal') || clean.contains('moderado') || clean.contains('medio')) {
      return 60;
    }
    if (clean.contains('intenso') || clean.contains('fuerte') || clean.contains('alto')) {
      return 80;
    }

    // Si es un parámetro personalizado
    if (index != null && total != null && total > 0) {
      return (((index + 1) * 100) / total).round();
    }

    return 60;
  }

  static IconData getIntensityIcon(String intensity) {
    final clean = intensity.trim().toLowerCase();
    if (clean.contains('muy ligero') || clean.contains('muy suave') || clean.contains('regenerativo')) {
      return Icons.spa_rounded;
    }
    if (clean.contains('muy intenso') || clean.contains('muy fuerte') || clean.contains('máximo') || clean.contains('maximo')) {
      return Icons.bolt_rounded;
    }
    if (clean.contains('ligero') || clean.contains('suave')) {
      return Icons.sentiment_satisfied_alt_rounded;
    }
    if (clean.contains('normal') || clean.contains('moderado') || clean.contains('medio')) {
      return Icons.fitness_center_rounded;
    }
    if (clean.contains('intenso') || clean.contains('fuerte') || clean.contains('alto')) {
      return Icons.local_fire_department_rounded;
    }
    return Icons.sports_score_rounded;
  }

  static String getIntensityDescription(String intensity) {
    final clean = intensity.trim().toLowerCase();
    if (clean.contains('muy ligero') || clean.contains('muy suave') || clean.contains('regenerativo')) {
      return 'Recuperación • Activación o sesión regenerativa';
    }
    if (clean.contains('muy intenso') || clean.contains('muy fuerte') || clean.contains('máximo') || clean.contains('maximo')) {
      return 'Al límite • Fatiga extrema y máximo esfuerzo';
    }
    if (clean.contains('ligero') || clean.contains('suave')) {
      return 'Suave • Calentamiento o baja exigencia';
    }
    if (clean.contains('normal') || clean.contains('moderado') || clean.contains('medio')) {
      return 'Buen ritmo • Carga adecuada y controlada';
    }
    if (clean.contains('intenso') || clean.contains('fuerte') || clean.contains('alto')) {
      return 'Exigente • Alta demanda física y táctica';
    }
    return 'Nivel personalizado de esfuerzo';
  }

  static ThemeData get light => dark; // Default dark theme for athletic feel

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
          error: error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 2,
          shadowColor: Colors.black45,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: divider, width: 1.2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          selectedColor: primary,
          labelStyle: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: divider),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          hintStyle: const TextStyle(color: textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: divider),
          ),
        ),
      );
}
