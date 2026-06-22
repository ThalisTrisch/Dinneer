import crypto from 'crypto';

const PREFIX = 'scrypt';
const SALT_BYTES = 16;
const KEY_LENGTH = 64;

export function hashPassword(senha: string): string {
  const salt = crypto.randomBytes(SALT_BYTES);
  const derived = crypto.scryptSync(senha, salt, KEY_LENGTH);
  return `${PREFIX}$${salt.toString('hex')}$${derived.toString('hex')}`;
}

export function isHashed(valor: string | null | undefined): boolean {
  return typeof valor === 'string' && valor.startsWith(`${PREFIX}$`);
}

export function verifyPassword(senha: string, hashArmazenado: string): boolean {
  const partes = hashArmazenado.split('$');
  if (partes.length !== 3 || partes[0] !== PREFIX) {
    return false;
  }

  const salt = Buffer.from(partes[1], 'hex');
  const esperado = Buffer.from(partes[2], 'hex');
  const derived = crypto.scryptSync(senha, salt, esperado.length);

  return esperado.length === derived.length && crypto.timingSafeEqual(esperado, derived);
}
