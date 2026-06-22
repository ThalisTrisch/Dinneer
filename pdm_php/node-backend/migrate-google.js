// Migração: torna tb_usuario_dn.nu_cpf opcional (login via Google não tem CPF).
// Uso:  node migrate-google.js
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || '200.19.1.18',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'thalistrisch',
  password: process.env.DB_PASSWORD || '123456',
  database: process.env.DB_NAME || 'thalistrisch',
  connectionTimeoutMillis: 5000,
});

(async () => {
  try {
    console.log(`Conectando em ${process.env.DB_NAME || 'thalistrisch'}@${process.env.DB_HOST || '200.19.1.18'}...`);
    await pool.query('ALTER TABLE tb_usuario_dn ALTER COLUMN nu_cpf DROP NOT NULL');
    const r = await pool.query(
      "SELECT is_nullable FROM information_schema.columns WHERE table_name='tb_usuario_dn' AND column_name='nu_cpf'"
    );
    console.log('nu_cpf aceita nulo?', r.rows[0] ? r.rows[0].is_nullable : '(coluna nao encontrada)');
    console.log('OK: migracao concluida. Pode apagar este arquivo.');
  } catch (err) {
    console.error('FALHOU:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
