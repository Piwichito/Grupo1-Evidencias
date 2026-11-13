// Repositorio de productos sobre MongoDB Atlas (Mongoose).
const Producto = require('../models/producto.model');

const aDto = (doc) => ({
  id: String(doc._id),
  nombre: doc.nombre,
  descripcion: doc.descripcion,
  precio: doc.precio,
  categoria: doc.categoria,
  disponible: doc.disponible,
});

class ProductoRepositoryMongo {
  async listar({ categoria } = {}) {
    const filtro = categoria ? { categoria } : {};
    const docs = await Producto.find(filtro).sort({ categoria: 1, nombre: 1 });
    return docs.map(aDto);
  }

  async buscarPorId(id) {
    const doc = await Producto.findById(id);
    return doc ? aDto(doc) : null;
  }

  async buscarPorIds(ids) {
    const docs = await Producto.find({ _id: { $in: ids } });
    return docs.map(aDto);
  }

  async buscarPorNombre(nombre) {
    const doc = await Producto.findOne({ nombre: new RegExp(`^${nombre.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, 'i') });
    return doc ? aDto(doc) : null;
  }

  async contar() {
    return Producto.countDocuments();
  }

  async crear(datos) {
    return aDto(await Producto.create(datos));
  }

  async actualizar(id, cambios) {
    const doc = await Producto.findByIdAndUpdate(id, cambios, { new: true, runValidators: true });
    return doc ? aDto(doc) : null;
  }
}

module.exports = { ProductoRepositoryMongo };
