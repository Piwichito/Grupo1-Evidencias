import 'package:flutter/material.dart';

/// Muestra un aviso breve en la parte inferior de la pantalla.
/// Reemplaza el aviso anterior si todavía está visible.
void mostrarAviso(
  BuildContext context,
  String mensaje, {
  bool esError = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: esError ? Colors.red.shade700 : null,
    ),
  );
}
