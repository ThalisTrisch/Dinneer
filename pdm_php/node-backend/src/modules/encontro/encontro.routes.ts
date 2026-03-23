import { Router } from 'express';
import { EncontroController } from './encontro.controller';

const router = Router();
const encontroController = new EncontroController();

/**
 * Rota: /api/v1/encontro/EncontroController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/EncontroController', (req, res, next) => {
  encontroController.handle(req, res, next);
});

export default router;
