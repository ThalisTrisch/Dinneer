// Migração: adiciona a coluna tb_cardapio_dn.nm_categoria (categoria do jantar).
// Uso:  node migrate-categoria.js
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
    await pool.query('ALTER TABLE tb_cardapio_dn ADD COLUMN IF NOT EXISTS nm_categoria VARCHAR(50)');
    const r = await pool.query(
      "SELECT column_name FROM information_schema.columns WHERE table_name='tb_cardapio_dn' AND column_name='nm_categoria'"
    );
    console.log(r.rows.length > 0 ? 'OK: coluna nm_categoria pronta. Pode apagar este arquivo.' : 'ATENCAO: coluna nao encontrada.');
  } catch (err) {
    console.error('FALHOU:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
