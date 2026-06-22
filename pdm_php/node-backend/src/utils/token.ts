import crypto from 'crypto';
import { config } from '../config/environment';

export interface TokenPayload {
  id_usuario: number;
  exp: number;
}

function assinar(corpo: string): string {
  return crypto.createHmac('sha256', config.auth.secret).update(corpo).digest('base64url');
}

export function gerarToken(id_usuario: number): string {
  const payload: TokenPayload = {
    id_usuario,
    exp: Math.floor(Date.now() / 1000) + config.auth.expiresInSeconds,
  };
  const corpo = Buffer.from(JSON.stringify(payload)).toString('base64url');
  return `${corpo}.${assinar(corpo)}`;
}

export function verificarToken(token: string): TokenPayload | null {
  const partes = token.split('.');
  if (partes.length !== 2) {
    return null;
  }

  const [corpo, assinatura] = partes;
  const esperada = assinar(corpo);
  const recebida = Buffer.from(assinatura);
  const correta = Buffer.from(esperada);

  if (recebida.length !== correta.length || !crypto.timingSafeEqual(recebida, correta)) {
    return null;
  }

  try {
    const payload = JSON.parse(Buffer.from(corpo, 'base64url').toString('utf8')) as TokenPayload;
    if (typeof payload.id_usuario !== 'number' || typeof payload.exp !== 'number') {
      return null;
    }
    if (payload.exp < Math.floor(Date.now() / 1000)) {
      return null;
    }
    return payload;
  } catch {
    return null;
  }
}
