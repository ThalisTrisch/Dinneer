import { Router } from 'express';
import { AvaliacaoController } from './avaliacao.controller';

const router = Router();
const avaliacaoController = new AvaliacaoController();

/**
 * Rota: /api/v1/avaliacao/AvaliacaoController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/AvaliacaoController', (req, res, next) => {
  avaliacaoController.handle(req, res, next);
});

export default router;
