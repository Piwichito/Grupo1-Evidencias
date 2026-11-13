// Repositorio de productos en memoria. Se usa en las pruebas y en el modo "demo" (sin base de datos).
const { generarId } = require('../utils/helpers');

class ProductoRepositoryMemory {
  constructor() {
    this.productos = [];
  }

  async listar({ categoria } = {}) {
    return this.productos.filter((p) => !categoria || p.categoria === categoria).map((p) => ({ ...p }));
  }

  async buscarPorId(id) {
    const p = this.productos.find((x) => x.id === id);
    return p ? { ...p } : null;
  }

  async buscarPorIds(ids) {
    return this.productos.filter((p) => ids.includes(p.id)).map((p) => ({ ...p }));
  }

  async buscarPorNombre(nombre) {
    const p = this.productos.find((x) => x.nombre.toLowerCase() === nombre.toLowerCase());
    return p ? { ...p } : null;
  }

  async contar() {
    return this.productos.length;
  }

  async crear(datos) {
    const producto = { id: generarId(), ...datos };
    this.productos.push(producto);
    return { ...producto };
  }

  async actualizar(id, cambios) {
    const p = this.productos.find((x) => x.id === id);
    if (!p) return null;
    Object.assign(p, cambios);
    return { ...p };
  }
}

module.exports = { ProductoRepositoryMemory };
