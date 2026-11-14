import 'package:flutter/material.dart';

/// Muestra un indicador de carga o un mensaje de error con botón "Reintentar"
/// mientras los datos no estén disponibles. Cuando ya hay datos, muestra [child].
/// Es reutilizable en todas las pantallas que obtienen datos de la API.
class VistaCarga extends StatelessWidget {
  const VistaCarga({
    super.key,
    required this.cargado,
    required this.error,
    required this.onReintentar,
    required this.child,
  });

  final bool cargado;
  final String? error;
  final VoidCallback onReintentar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (cargado) return child;

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
