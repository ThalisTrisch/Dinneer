import { Pool, PoolConfig } from 'pg';
import { config } from './environment';

const poolConfig: PoolConfig = {
  host: config.database.host,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  max: 20, // Máximo de conexões no pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

export const pool = new Pool(poolConfig);

// Testa a conexão ao iniciar
pool.on('connect', () => {
  console.log('Conectado ao banco de dados PostgreSQL');
});

pool.on('error', (err) => {
  console.error('Erro inesperado no pool de conexões:', err);
  process.exit(-1);
});
