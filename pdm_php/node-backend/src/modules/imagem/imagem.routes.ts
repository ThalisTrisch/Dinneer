import { Router } from 'express';
import { ImagemController } from './imagem.controller';

const router = Router();
const imagemController = new ImagemController();

/**
 * Rota: /api/v1/imagem/ImagemController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/ImagemController', (req, res, next) => {
  imagemController.handle(req, res, next);
});

export default router;
