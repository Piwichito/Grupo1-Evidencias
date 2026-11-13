const { Router } = require('express');
const rol = require('../middlewares/rol');
const crearControlador = require('../controllers/pedido.controller');

module.exports = (service) => {
  const c = crearControlador(service);
  const router = Router();
  router.get('/', c.listar);
  router.get('/:id', c.obtener);
  router.post('/', rol, c.crear);
  router.patch('/:id/estado', rol, c.cambiarEstado);
  return router;
};
