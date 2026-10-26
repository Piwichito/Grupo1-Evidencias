import '../models/categoria.dart';
import '../models/producto.dart';

/// Carta de ejemplo del restaurante ficticio "Sabor Peruano".
/// Más adelante (Avance 3) estos datos se guardarán en SQLite / API REST.
const List<Producto> menuDemo = [
  // Entradas
  Producto(
    id: 1,
    nombre: 'Ceviche clásico',
    descripcion: 'Pescado fresco, limón, cebolla y camote.',
    precio: 28.00,
    categoria: Categoria.entradas,
  ),
  Producto(
    id: 2,
    nombre: 'Papa a la huancaína',
    descripcion: 'Papa amarilla con crema de ají y huevo.',
    precio: 14.00,
    categoria: Categoria.entradas,
  ),
  Producto(
    id: 3,
    nombre: 'Anticuchos',
    descripcion: 'Brochetas de corazón con papa y ají.',
    precio: 18.00,
    categoria: Categoria.entradas,
  ),
  // Platos de fondo
  Producto(
    id: 4,
    nombre: 'Lomo saltado',
    descripcion: 'Lomo fino, cebolla, tomate, papas y arroz.',
    precio: 26.00,
    categoria: Categoria.fondos,
  ),
  Producto(
    id: 5,
    nombre: 'Ají de gallina',
    descripcion: 'Pollo deshilachado en crema de ají amarillo.',
    precio: 22.00,
    categoria: Categoria.fondos,
  ),
  Producto(
    id: 6,
    nombre: 'Arroz con mariscos',
    descripcion: 'Arroz con mariscos y salsa criolla.',
    precio: 30.00,
    categoria: Categoria.fondos,
  ),
  Producto(
    id: 7,
    nombre: 'Tacu tacu con bistec',
    descripcion: 'Tacu tacu con bistec y huevo frito.',
    precio: 25.00,
    categoria: Categoria.fondos,
    disponible: false, // Ejemplo de producto agotado.
  ),
  // Bebidas
  Producto(
    id: 8,
    nombre: 'Chicha morada (jarra)',
    descripcion: 'Jarra de 1 litro.',
    precio: 12.00,
    categoria: Categoria.bebidas,
  ),
  Producto(
    id: 9,
    nombre: 'Limonada frozen',
    descripcion: 'Vaso grande.',
    precio: 8.00,
    categoria: Categoria.bebidas,
  ),
  Producto(
    id: 10,
    nombre: 'Gaseosa personal',
    descripcion: 'Botella de 500 ml.',
    precio: 5.00,
    categoria: Categoria.bebidas,
  ),
  // Postres
  Producto(
    id: 11,
    nombre: 'Suspiro limeño',
    descripcion: 'Manjar blanco con merengue de oporto.',
    precio: 10.00,
    categoria: Categoria.postres,
  ),
  Producto(
    id: 12,
    nombre: 'Mazamorra morada',
    descripcion: 'Postre tradicional con frutas y canela.',
    precio: 8.00,
    categoria: Categoria.postres,
  ),
];
