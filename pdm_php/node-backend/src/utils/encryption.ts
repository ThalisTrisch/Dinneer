import crypto from 'crypto';
import { config } from '../config/environment';

/**
 * Criptografa uma string usando AES-256-CBC
 * Compatível com openssl_encrypt do PHP
 */
export function encrypt(text: string): string {
  // Garante que a chave tenha exatamente 32 bytes
  const key = Buffer.alloc(32);
  Buffer.from(config.encryption.key).copy(key);
  
  const cipher = crypto.createCipheriv(
    'aes-256-cbc',
    key,
    Buffer.from(config.encryption.iv)
  );
  
  let encrypted = cipher.update(text, 'utf8', 'base64');
  encrypted += cipher.final('base64');
  
  return encrypted;
}

/**
 * Descriptografa uma string usando AES-256-CBC
 * Compatível com openssl_decrypt do PHP
 */
export function decrypt(encryptedText: string): string {
  // Garante que a chave tenha exatamente 32 bytes
  const key = Buffer.alloc(32);
  Buffer.from(config.encryption.key).copy(key);
  
  const decipher = crypto.createDecipheriv(
    'aes-256-cbc',
    key,
    Buffer.from(config.encryption.iv)
  );
  
  let decrypted = decipher.update(encryptedText, 'base64', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
