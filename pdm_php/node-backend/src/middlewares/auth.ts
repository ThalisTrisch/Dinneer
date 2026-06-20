import { Request, Response, NextFunction } from 'express';
import { verificarToken } from '../utils/token';

declare global {
  namespace Express {
    interface Request {
      usuarioId?: number;
    }
  }
}

export function autenticacaoOpcional(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (header && header.startsWith('Bearer ')) {
    const payload = verificarToken(header.substring(7));
    if (payload) {
      req.usuarioId = payload.id_usuario;
    }
  }
  next();
}

export function exigirAutenticacao(req: Request, res: Response, next: NextFunction): void {
  if (!req.usuarioId) {
    res.status(401).json({
      operacao: 'auth',
      NumMens: 1,
      Mensagem: 'Autenticação necessária.',
      registros: 0,
      dados: null,
    });
    return;
  }
  next();
}
