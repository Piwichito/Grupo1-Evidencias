import 'package:flutter/material.dart';

/// Colores y tema general de la aplicación.
/// Centralizar el estilo aquí evita repetir colores en cada pantalla.
class AppColors {
  AppColors._(); // Clase de utilidad: no se instancia.

  static const Color primario = Color(0xFFC62828); // rojo cálido
  static const Color secundario = Color(0xFFEF6C00); // naranja
  static const Color fondo = Color(0xFFFFF8F3);
  static const Color texto = Color(0xFF3E2723);
}

class AppTheme {
  AppTheme._();

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.primario,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primario,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
