// Reglas de negocio de los pedidos. No conoce Express ni MongoDB: recibe los repositorios por parámetro
// (inyección de dependencias), lo que permite probarlo con repositorios en memoria.
const { ESTADOS, LISTA_ESTADOS, siguienteEstado, estaAbierto } = require('../utils/estados');
const { puedeCrearPedidos, puedeCambiarEstado } = require('../utils/permisos');
const { errorValidacion, noEncontrado, prohibido, conflicto, reglaNegocio } = require('../utils/errors');
const { redondear, esIdValido } = require('../utils/helpers');
const { validarNuevoPedido, validarCambioEstado } = require('../validators/pedido.validator');

class PedidoService {
  constructor({ pedidoRepo, productoRepo, reloj = () => new Date() }) {
    this.pedidoRepo = pedidoRepo;
    this.productoRepo = productoRepo;
    this.reloj = reloj;
  }

  async listar({ estado } = {}) {
    if (estado !== undefined && !LISTA_ESTADOS.includes(estado)) {
      throw errorValidacion([`estado: debe ser uno de ${LISTA_ESTADOS.join(', ')}`]);
    }
    return this.pedidoRepo.listar({ estado });
  }

  async obtener(id) {
    if (!esIdValido(id)) throw errorValidacion(['id: formato de id inválido']);
    const pedido = await this.pedidoRepo.buscarPorId(id);
    if (!pedido) throw noEncontrado('El pedido no existe');
    return pedido;
  }

  async crear(body, rol) {
    if (!puedeCrearPedidos(rol)) throw prohibido('El rol cocinero no puede registrar pedidos');
    const datos = validarNuevoPedido(body);

    // El precio y el nombre se toman de la base de datos (no del cliente) para evitar manipulaciones.
    const productos = await this.productoRepo.buscarPorIds(datos.items.map((i) => i.productoId));
    const porId = new Map(productos.map((p) => [p.id, p]));

    const items = [];
    const problemas = [];
    for (const it of datos.items) {
      const producto = porId.get(it.productoId);
      if (!producto) {
        problemas.push(`El producto ${it.productoId} no existe`);
      } else if (!producto.disponible) {
        problemas.push(`${producto.nombre}: producto agotado`);
      } else {
        items.push({
          productoId: producto.id,
          nombre: producto.nombre,
          precioUnitario: producto.precio,
          cantidad: it.cantidad,
          subtotal: redondear(producto.precio * it.cantidad),
        });
      }
    }
    if (problemas.length > 0) throw reglaNegocio(problemas);

    const total = redondear(items.reduce((suma, i) => suma + i.subtotal, 0));
    return this.pedidoRepo.crear({
      mesa: datos.mesa,
      cliente: datos.cliente,
      observaciones: datos.observaciones,
      items,
      total,
      estado: ESTADOS.RECIBIDO,
      fecha: this.reloj(),
    });
  }

  async cambiarEstado(id, body, rol) {
    const nuevo = validarCambioEstado(body);
    const pedido = await this.obtener(id);

    if (!estaAbierto(pedido.estado)) {
      throw conflicto(`El pedido ya está ${pedido.estado} y no puede cambiar de estado`);
    }
    const esAnulacion = nuevo === ESTADOS.ANULADO;
    if (!esAnulacion && siguienteEstado(pedido.estado) !== nuevo) {
      throw conflicto(`Transición no permitida: de ${pedido.estado} a ${nuevo}`);
    }
    if (!puedeCambiarEstado(rol, pedido.estado, nuevo)) {
      throw prohibido(`El rol ${rol} no puede pasar el pedido de ${pedido.estado} a ${nuevo}`);
    }

    // Actualización condicionada al estado leído: si otro usuario lo cambió antes, no se pisa.
    const actualizado = await this.pedidoRepo.actualizarEstado(id, pedido.estado, nuevo);
    if (!actualizado) {
      throw conflicto('El pedido fue modificado por otro usuario. Actualiza la lista e inténtalo de nuevo');
    }
    return actualizado;
  }
}

module.exports = { PedidoService };
