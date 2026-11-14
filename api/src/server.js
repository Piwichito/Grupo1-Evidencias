// Punto de entrada: elige MongoDB Atlas o memoria según DB_MODE y levanta el servidor.
const { puerto, modoDb, mongoUri } = require('./config/env');
const { crearApp } = require('./app');
const { cargarMenu } = require('./seed/cargar-menu');

async function main() {
  let pedidoRepo;
  let productoRepo;

  if (modoDb === 'memory') {
    const { PedidoRepositoryMemory } = require('./repositories/pedido.repository.memory');
    const { ProductoRepositoryMemory } = require('./repositories/producto.repository.memory');
    pedidoRepo = new PedidoRepositoryMemory();
    productoRepo = new ProductoRepositoryMemory();
    console.log('Modo DEMO: los datos están en memoria y se pierden al cerrar el servidor.');
  } else {
    const { conectarMongo } = require('./config/db');
    const { PedidoRepositoryMongo } = require('./repositories/pedido.repository.mongo');
    const { ProductoRepositoryMongo } = require('./repositories/producto.repository.mongo');
    await conectarMongo(mongoUri);
    pedidoRepo = new PedidoRepositoryMongo();
    productoRepo = new ProductoRepositoryMongo();
  }

  // Si la carta está vacía, se carga la carta inicial automáticamente.
  if ((await productoRepo.contar()) === 0) {
    const creados = await cargarMenu(productoRepo);
    console.log(`Carta inicial cargada: ${creados} productos.`);
  }

  const app = crearApp({ pedidoRepo, productoRepo });
  app.listen(puerto, '0.0.0.0', () => console.log(`API escuchando en http://localhost:${puerto}/api/health`));
}

main().catch((err) => {
  console.error('No se pudo iniciar la API:', err.message);
  process.exit(1);
});
