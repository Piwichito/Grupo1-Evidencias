import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria.dart';
import '../providers/menu_provider.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/producto_card.dart';
import '../widgets/vista_carga.dart';

/// Pantalla: carta del menú (solo consulta), obtenida de la API y filtrada por categoría.
class CartaScreen extends StatefulWidget {
  const CartaScreen({super.key});

  @override
  State<CartaScreen> createState() => _CartaScreenState();
}

class _CartaScreenState extends State<CartaScreen> {
  Categoria _categoria = Categoria.entradas;

  @override
  Widget build(BuildContext context) {
    // watch: la pantalla se redibuja cuando el MenuProvider cambia.
    final menu = context.watch<MenuProvider>();
    final productos = menu.productosDe(_categoria);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carta del menú'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: menu.cargando ? null : menu.cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: VistaCarga(
        cargado: menu.cargado,
        error: menu.error,
        onReintentar: menu.cargar,
        child: Column(
          children: [
            FiltroCategorias(
              seleccionada: _categoria,
              onSeleccionar: (c) => setState(() => _categoria = c),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: menu.cargar,
                child: productos.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text('No hay productos en esta categoría'),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: productos.length,
                        itemBuilder: (context, indice) =>
                            ProductoCard(producto: productos[indice]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
