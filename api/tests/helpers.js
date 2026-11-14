// Utilidades para las pruebas: arma la API con repositorios en memoria y la carta inicial.
const { crearApp } = require('../src/app');
const { PedidoRepositoryMemory } = require('../src/repositories/pedido.repository.memory');
const { ProductoRepositoryMemory } = require('../src/repositories/producto.repository.memory');
const { cargarMenu } = require('../src/seed/cargar-menu');
const { PedidoService } = require('../src/services/pedido.service');

async function crearEntorno() {
  const pedidoRepo = new PedidoRepositoryMemory();
  const productoRepo = new ProductoRepositoryMemory();
  await cargarMenu(productoRepo);
  const reloj = () => new Date('2026-11-08T15:00:00.000Z');
  const app = crearApp({ pedidoRepo, productoRepo, logs: false, reloj });
  const pedidoService = new PedidoService({ pedidoRepo, productoRepo, reloj });
  return { app, pedidoRepo, productoRepo, pedidoService };
}

// Busca un producto de la carta por nombre.
async function producto(productoRepo, nombre) {
  return productoRepo.buscarPorNombre(nombre);
}

module.exports = { crearEntorno, producto };
