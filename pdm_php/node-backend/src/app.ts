import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import usuarioRoutes from './modules/usuario/usuario.routes';
import localRoutes from './modules/local/local.routes';
import cardapioRoutes from './modules/cardapio/cardapio.routes';
import encontroRoutes from './modules/encontro/encontro.routes';
import avaliacaoRoutes from './modules/avaliacao/avaliacao.routes';
import imagemRoutes from './modules/imagem/imagem.routes';

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
    // CORS - permite requisições do Flutter
    this.app.use(cors());

    // Parse JSON
    this.app.use(express.json());

    // Parse URL-encoded (form data)
    this.app.use(express.urlencoded({ extended: true }));
  }

  /**
   * Configura rotas
   */
  private routes(): void {
    // Rota raiz
    this.app.get('/', (req: Request, res: Response) => {
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

    // Rota 404
    this.app.use((req: Request, res: Response) => {
      res.status(404).json({
        error: 'Rota não encontrada',
        path: req.path,
      });
    });
  }
}
