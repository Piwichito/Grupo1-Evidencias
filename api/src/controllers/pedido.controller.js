const asyncHandler = require('../middlewares/async-handler');

// Controladores: traducen la petición HTTP a llamadas al servicio y arman la respuesta.
module.exports = (service) => ({
  listar: asyncHandler(async (req, res) => {
    res.json(await service.listar({ estado: req.query.estado }));
  }),
  obtener: asyncHandler(async (req, res) => {
    res.json(await service.obtener(req.params.id));
  }),
  crear: asyncHandler(async (req, res) => {
    const pedido = await service.crear(req.body, req.rol);
    res.status(201).location(`/api/pedidos/${pedido.id}`).json(pedido);
  }),
  cambiarEstado: asyncHandler(async (req, res) => {
    res.json(await service.cambiarEstado(req.params.id, req.body, req.rol));
  }),
});
