// Repositorio de pedidos en memoria (pruebas y modo "demo").
const { generarId } = require('../utils/helpers');

const copiar = (p) => ({ ...p, items: p.items.map((i) => ({ ...i })) });

class PedidoRepositoryMemory {
  constructor() {
    this.pedidos = [];
    this.secuencia = 0;
  }

  // Más recientes primero, igual que en la versión con MongoDB.
  async listar({ estado } = {}) {
    return this.pedidos
      .filter((p) => !estado || p.estado === estado)
      .sort((a, b) => b.numero - a.numero)
      .map(copiar);
  }

  async buscarPorId(id) {
    const p = this.pedidos.find((x) => x.id === id);
    return p ? copiar(p) : null;
  }

  async crear(datos) {
    const { fecha, ...resto } = datos;
    const ahora = fecha.toISOString();
    const pedido = {
      id: generarId(),
      numero: ++this.secuencia,
      ...resto,
      creadoEn: ahora,
      actualizadoEn: ahora,
    };
    this.pedidos.push(pedido);
    return copiar(pedido);
  }

  // Solo cambia el estado si el pedido sigue en "estadoEsperado". Devuelve null si no.
  async actualizarEstado(id, estadoEsperado, nuevoEstado) {
    const p = this.pedidos.find((x) => x.id === id && x.estado === estadoEsperado);
    if (!p) return null;
    p.estado = nuevoEstado;
    p.actualizadoEn = new Date().toISOString();
    return copiar(p);
  }
}

module.exports = { PedidoRepositoryMemory };
