import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import { config } from './config/environment';
import { autenticacaoOpcional } from './middlewares/auth';
import usuarioRoutes from './modules/usuario/usuario.routes';
import localRoutes from './modules/local/local.routes';
import cardapioRoutes from './modules/cardapio/cardapio.routes';
import encontroRoutes from './modules/encontro/encontro.routes';
import avaliacaoRoutes from './modules/avaliacao/avaliacao.routes';
import imagemRoutes from './modules/imagem/imagem.routes';
import notificationRoutes from './modules/notification/notification.routes';

/**
 * Configuração do Express App
 */
export class App {
  public app: Application;

  constructor() {
    this.app = express();
    this.middlewares();
    this.routes();
  }

  /**
   * Configura middlewares
   */
  private middlewares(): void {
    // CORS - libera apps mobile (sem Origin) e origens web da allowlist
    this.app.use(
      cors({
        origin: (origin, callback) => {
          if (!origin || config.server.corsOrigins.includes(origin)) {
            callback(null, true);
          } else {
            callback(new Error('Origem não autorizada pelo CORS'));
          }
        },
      })
    );

    // Parse JSON
    this.app.use(express.json());

    // Parse URL-encoded (form data)
    this.app.use(express.urlencoded({ extended: true }));

    // Popula req.usuarioId quando há um Bearer token válido
    this.app.use(autenticacaoOpcional);
  }

  /**
   * Configura rotas
   */
  private routes(): void {
    // Rota raiz
    this.app.get('/', (_req: Request, res: Response) => {
      res.json({
        message: 'Dinneer API - Node.js + TypeScript',
        version: '1.0.0',
        endpoints: [
          'GET/POST /api/v1/usuario/UsuarioController?operacao=loginUsuario',
          'GET /api/v1/usuario/UsuarioController?operacao=getUsuarios',
          'GET /api/v1/usuario/UsuarioController?operacao=getUsuario&id_usuario=1',
          'POST /api/v1/usuario/UsuarioController?operacao=createUsuario',
        ],
      });
    });

    // Rotas de usuário
    this.app.use('/api/v1/usuario', usuarioRoutes);

    // Rotas de local
    this.app.use('/api/v1/local', localRoutes);

    // Rotas de cardapio
    this.app.use('/api/v1/cardapio', cardapioRoutes);

    // Rotas de encontro
    this.app.use('/api/v1/encontro', encontroRoutes);

    // Rotas de avaliacao
    this.app.use('/api/v1/avaliacao', avaliacaoRoutes);

    // Rotas de imagem
    this.app.use('/api/v1/imagem', imagemRoutes);

    // Rotas de notificação (FCM push notifications)
    this.app.use('/api/v1/notification', notificationRoutes);

    // Rota 404
    this.app.use((req: Request, res: Response) => {
      res.status(404).json({
        error: 'Rota não encontrada',
        path: req.path,
      });
    });
  }
}
