import 'package:flutter/material.dart';

import '../data/menu_demo.dart';
import '../models/categoria.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/producto_card.dart';

/// Pantalla: carta del menú (solo consulta) filtrada por categoría.
class CartaScreen extends StatefulWidget {
  const CartaScreen({super.key});

  @override
  State<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends State<CartaScreen> {
  Categoria _categoria = Categoria.entradas;

  @override
  Widget build(BuildContext context) {
    final productos =
        menuDemo.where((p) => p.categoria == _categoria).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Carta del menú')),
      body: Column(
        children: [
          FiltroCategorias(
            seleccionada: _categoria,
            onSeleccionar: (c) => setState(() => _categoria = c),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, indice) =>
                  ProductoCard(producto: productos[indice]),
            ),
          ),
        ],
      ),
    );
  }
}
