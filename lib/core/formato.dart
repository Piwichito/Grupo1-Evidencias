/// Funciones de formato reutilizables en toda la aplicación.
library;

/// Convierte un monto a texto en soles. Ejemplo: 12.5 -> "S/ 12.50".
String formatearSoles(double monto) => 'S/ ${monto.toStringAsFixed(2)}';

/// Devuelve la hora de una fecha como "HH:mm". Ejemplo: "14:05".
String formatearHora(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}
