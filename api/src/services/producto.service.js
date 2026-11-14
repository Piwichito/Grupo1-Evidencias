const { CATEGORIAS } = require('../utils/estados');
const { puedeGestionarCarta } = require('../utils/permisos');
const { errorValidacion, noEncontrado, prohibido, conflicto } = require('../utils/errors');
const { esIdValido } = require('../utils/helpers');
const { validarNuevoProducto, validarCambiosProducto } = require('../validators/pedido.validator');

class ProductoService {
  constructor({ productoRepo }) {
    this.productoRepo = productoRepo;
  }

  async listar({ categoria } = {}) {
    if (categoria !== undefined && !CATEGORIAS.includes(categoria)) {
      throw errorValidacion([`categoria: debe ser una de ${CATEGORIAS.join(', ')}`]);
    }
    return this.productoRepo.listar({ categoria });
  }

  async obtener(id) {
    if (!esIdValido(id)) throw errorValidacion(['id: formato de id inválido']);
    const producto = await this.productoRepo.buscarPorId(id);
    if (!producto) throw noEncontrado('El producto no existe');
    return producto;
  }

  async crear(body, rol) {
    if (!puedeGestionarCarta(rol)) throw prohibido('Solo el administrador puede modificar la carta');
    const datos = validarNuevoProducto(body);
    if (await this.productoRepo.buscarPorNombre(datos.nombre)) {
      throw conflicto(`Ya existe un producto llamado "${datos.nombre}"`);
    }
    return this.productoRepo.crear(datos);
  }

  async actualizar(id, body, rol) {
    if (!puedeGestionarCarta(rol)) throw prohibido('Solo el administrador puede modificar la carta');
    if (!esIdValido(id)) throw errorValidacion(['id: formato de id inválido']);
    const cambios = validarCambiosProducto(body);
    const producto = await this.productoRepo.actualizar(id, cambios);
    if (!producto) throw noEncontrado('El producto no existe');
    return producto;
  }
}

module.exports = { ProductoService };
