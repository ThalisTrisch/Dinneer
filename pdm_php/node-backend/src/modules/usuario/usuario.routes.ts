import { Router } from 'express';
import { UsuarioController } from './usuario.controller';

const router = Router();
const usuarioController = new UsuarioController();

/**
 * ROTAS ANTIGAS (PHP) - Mantidas para compatibilidade
 * Rota: /api/v1/usuario/UsuarioController
 * Aceita GET e POST com query param ?operacao=
 */
router.all('/UsuarioController', (req, res, next) => {
  usuarioController.handle(req, res, next);
});

/**
 * NOVAS ROTAS REST (Node.js)
 */

// POST /api/v1/usuario/login - Login de usuário
router.post('/login', async (req, res, next) => {
  req.query.operacao = 'loginUsuario';
  usuarioController.handle(req, res, next);
});

// POST /api/v1/usuario - Criar novo usuário
router.post('/', async (req, res, next) => {
  req.query.operacao = 'createUsuario';
  usuarioController.handle(req, res, next);
});

// GET /api/v1/usuario - Listar todos os usuários
router.get('/', async (req, res, next) => {
  req.query.operacao = 'getUsuarios';
  usuarioController.handle(req, res, next);
});

// GET /api/v1/usuario/:id - Buscar usuário por ID
router.get('/:id', async (req, res, next) => {
  req.query.operacao = 'getUsuario';
  req.query.id_usuario = req.params.id;
  usuarioController.handle(req, res, next);
});

// PUT /api/v1/usuario/:id/foto - Atualizar foto de perfil
router.put('/:id/foto', async (req, res, next) => {
  req.query.operacao = 'atualizarFotoPerfil';
  req.body.id_usuario = req.params.id;
  usuarioController.handle(req, res, next);
});

// DELETE /api/v1/usuario/:id - Deletar usuário
router.delete('/:id', async (req, res, next) => {
  req.query.operacao = 'deleteUsuario';
  req.query.id_usuario = req.params.id;
  usuarioController.handle(req, res, next);
});

export default router;
