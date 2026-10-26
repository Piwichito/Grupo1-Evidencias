import 'package:flutter/material.dart';

import '../models/categoria.dart';

/// Fila horizontal de chips para filtrar el menú por categoría.
class FiltroCategorias extends StatelessWidget {
  const FiltroCategorias({
    super.key,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  final Categoria seleccionada;
  final ValueChanged<Categoria> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final categoria in Categoria.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria.etiqueta),
                selected: categoria == seleccionada,
                onSelected: (_) => onSeleccionar(categoria),
              ),
            ),
        ],
      ),
    );
  }
}
