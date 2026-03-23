import dotenv from 'dotenv';

dotenv.config();

export const config = {
  database: {
    host: process.env.DB_HOST || '200.19.1.18',
    port: parseInt(process.env.DB_PORT || '5432'),
    user: process.env.DB_USER || 'thalistrisch',
    password: process.env.DB_PASSWORD || '123456',
    database: process.env.DB_NAME || 'thalistrisch',
  },
  server: {
    port: parseInt(process.env.PORT || '3000'),
  },
  encryption: {
    key: process.env.ENCRYPTION_KEY || 'sua_chave_secreta_de_32_bytes',
    iv: process.env.ENCRYPTION_IV || '1234567891234567',
  },
};
