// Migração: adiciona a coluna tb_usuario_dn.vl_foto_capa (imagem de capa do perfil).
// Uso:  node migrate-foto-capa.js
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
    await pool.query('ALTER TABLE tb_usuario_dn ADD COLUMN IF NOT EXISTS vl_foto_capa VARCHAR(255)');
    const r = await pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_name='tb_usuario_dn' AND column_name='vl_foto_capa'"
    );
    console.log('coluna vl_foto_capa existe?', r.rows[0] ? 'sim' : 'nao');
    console.log('OK: migracao concluida. Pode apagar este arquivo.');
  } catch (err) {
    console.error('FALHOU:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
