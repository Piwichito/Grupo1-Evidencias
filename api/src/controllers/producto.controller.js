const asyncHandler = require('../middlewares/async-handler');

module.exports = (service) => ({
  listar: asyncHandler(async (req, res) => {
    res.json(await service.listar({ categoria: req.query.categoria }));
  }),
  obtener: asyncHandler(async (req, res) => {
    res.json(await service.obtener(req.params.id));
  }),
  crear: asyncHandler(async (req, res) => {
    const producto = await service.crear(req.body, req.rol);
    res.status(201).location(`/api/productos/${producto.id}`).json(producto);
  }),
  actualizar: asyncHandler(async (req, res) => {
    res.json(await service.actualizar(req.params.id, req.body, req.rol));
  }),
});
