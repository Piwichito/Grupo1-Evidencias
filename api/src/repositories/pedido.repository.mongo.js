// Repositorio de pedidos sobre MongoDB Atlas (Mongoose).
const Pedido = require('../models/pedido.model');
const Contador = require('../models/contador.model');

// Convierte el documento de Mongo en el objeto JSON que devuelve la API.
const aDto = (doc) => ({
  id: String(doc._id),
  numero: doc.numero,
  mesa: doc.mesa,
  cliente: doc.cliente,
  observaciones: doc.observaciones,
  estado: doc.estado,
  items: doc.items.map((i) => ({
    productoId: String(i.productoId),
    nombre: i.nombre,
    precioUnitario: i.precioUnitario,
    cantidad: i.cantidad,
    subtotal: i.subtotal,
  })),
  total: doc.total,
  creadoEn: doc.creadoEn.toISOString(),
  actualizadoEn: doc.actualizadoEn.toISOString(),
});

class PedidoRepositoryMongo {
  async listar({ estado } = {}) {
    const filtro = estado ? { estado } : {};
    const docs = await Pedido.find(filtro).sort({ numero: -1 });
    return docs.map(aDto);
  }

  async buscarPorId(id) {
    const doc = await Pedido.findById(id);
    return doc ? aDto(doc) : null;
  }

  async crear(datos) {
    // Incrementa el contador de forma atómica para obtener el siguiente número de pedido.
    const contador = await Contador.findByIdAndUpdate('pedido', { $inc: { seq: 1 } }, { new: true, upsert: true });
    const { fecha, ...resto } = datos;
    const doc = await Pedido.create({ ...resto, numero: contador.seq });
    return aDto(doc);
  }

  // Solo actualiza si el pedido sigue en "estadoEsperado" (evita que dos usuarios se pisen).
  async actualizarEstado(id, estadoEsperado, nuevoEstado) {
    const doc = await Pedido.findOneAndUpdate({ _id: id, estado: estadoEsperado }, { estado: nuevoEstado }, { new: true });
    return doc ? aDto(doc) : null;
  }
}

module.exports = { PedidoRepositoryMongo };
