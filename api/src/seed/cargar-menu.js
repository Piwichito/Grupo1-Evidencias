// Inserta en el repositorio los productos de la carta que todavía no existan (no duplica).
const menu = require('./menu');

async function cargarMenu(productoRepo) {
  let creados = 0;
  for (const producto of menu) {
    if (!(await productoRepo.buscarPorNombre(producto.nombre))) {
      await productoRepo.crear({ disponible: true, ...producto });
      creados++;
    }
  }
  return creados;
}

module.exports = { cargarMenu };
