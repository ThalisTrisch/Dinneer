import { Router } from 'express';
import { LocalController } from './local.controller';

const router = Router();
const localController = new LocalController();

/**
 * ROTAS ANTIGAS (PHP) - Mantidas para compatibilidade
 * Rota: /api/v1/local/LocalController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/LocalController', (req, res, next) => {
  localController.handle(req, res, next);
});

/**
 * NOVAS ROTAS REST (Node.js)
 */

// POST /api/v1/local - Criar novo local
router.post('/', async (req, res, next) => {
  req.query.operacao = 'createLocal';
  localController.handle(req, res, next);
});

// GET /api/v1/local - Listar todos os locais
router.get('/', async (req, res, next) => {
  req.query.operacao = 'getLocais';
  localController.handle(req, res, next);
});

// GET /api/v1/local/meus/:id_usuario - Buscar locais do usuário
router.get('/meus/:id_usuario', async (req, res, next) => {
  req.query.operacao = 'getMeusLocais';
  req.query.id_usuario = req.params.id_usuario;
  localController.handle(req, res, next);
});

// GET /api/v1/local/:id - Buscar local por ID
router.get('/:id', async (req, res, next) => {
  req.query.operacao = 'getLocal';
  req.query.id_local = req.params.id;
  localController.handle(req, res, next);
});

// DELETE /api/v1/local/:id - Deletar local
router.delete('/:id', async (req, res, next) => {
  req.query.operacao = 'deleteLocal';
  req.query.id_local = req.params.id;
  localController.handle(req, res, next);
});

export default router;
