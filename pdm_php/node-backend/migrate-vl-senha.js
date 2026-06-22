// Migração: amplia tb_usuario_dn.vl_senha para VARCHAR(255) (necessário p/ o hash scrypt).
// Uso:  node migrate-vl-senha.js
// Reusa as mesmas variaveis do .env que o backend ja usa.
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
    const antes = await pool.query(
      "SELECT character_maximum_length FROM information_schema.columns WHERE table_name='tb_usuario_dn' AND column_name='vl_senha'"
    );
    console.log('Tamanho atual de vl_senha:', antes.rows[0] ? antes.rows[0].character_maximum_length : '(coluna nao encontrada)');

    await pool.query('ALTER TABLE tb_usuario_dn ALTER COLUMN vl_senha TYPE VARCHAR(255)');

    const depois = await pool.query(
      "SELECT character_maximum_length FROM information_schema.columns WHERE table_name='tb_usuario_dn' AND column_name='vl_senha'"
    );
    console.log('Novo tamanho de vl_senha:', depois.rows[0].character_maximum_length);
    console.log('OK: migracao concluida. Pode apagar este arquivo.');
  } catch (err) {
    console.error('FALHOU:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
