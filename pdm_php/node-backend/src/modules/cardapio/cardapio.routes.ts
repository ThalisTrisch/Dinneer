import { Router } from 'express';
import { CardapioController } from './cardapio.controller';

const router = Router();
const cardapioController = new CardapioController();

/**
 * ROTAS ANTIGAS (PHP) - Mantidas para compatibilidade
 * Rota: /api/v1/cardapio/CardapioController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/CardapioController', (req, res, next) => {
  cardapioController.handle(req, res, next);
});

/**
 * NOVAS ROTAS REST (Node.js)
 */

// POST /api/v1/cardapio/jantar - Criar novo jantar
router.post('/jantar', async (req, res, next) => {
  req.query.operacao = 'createJantar';
  cardapioController.handle(req, res, next);
});

// GET /api/v1/cardapio/disponiveis - Listar cardápios disponíveis
router.get('/disponiveis', async (req, res, next) => {
  req.query.operacao = 'getCardapiosDisponiveis';
  cardapioController.handle(req, res, next);
});

// GET /api/v1/cardapio/meu/:id_local - Buscar cardápio do local
router.get('/meu/:id_local', async (req, res, next) => {
  req.query.operacao = 'getMeuCardapio';
  req.query.id_local = req.params.id_local;
  cardapioController.handle(req, res, next);
});

// PUT /api/v1/cardapio/jantar/:id - Atualizar jantar
router.put('/jantar/:id', async (req, res, next) => {
  req.query.operacao = 'updateJantar';
  req.body.id_cardapio = req.params.id;
  cardapioController.handle(req, res, next);
});

// DELETE /api/v1/cardapio/jantar/:id - Deletar jantar
router.delete('/jantar/:id', async (req, res, next) => {
  req.query.operacao = 'deleteCardapio';
  req.query.id_cardapio = req.params.id;
  cardapioController.handle(req, res, next);
});

// GET /api/v1/cardapio/jantar/:id - Buscar jantar por ID
router.get('/jantar/:id', async (req, res, next) => {
  req.query.operacao = 'getJantar';
  req.query.id_cardapio = req.params.id;
  cardapioController.handle(req, res, next);
});

// GET /api/v1/cardapio - Listar todos os cardápios
router.get('/', async (req, res, next) => {
  req.query.operacao = 'getCardapios';
  cardapioController.handle(req, res, next);
});

export default router;
