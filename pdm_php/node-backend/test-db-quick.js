#!/usr/bin/env node
/**
 * Quick Database Connection Test
 * Tests PostgreSQL connection with current .env settings
 */

require('dotenv').config();
const { Pool } = require('pg');

const config = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'postgres',
  connectionTimeoutMillis: 5000,
};

console.log('🔍 Testing Database Connection...\n');
console.log('📋 Configuration:');
console.log(`   Host: ${config.host}`);
console.log(`   Port: ${config.port}`);
console.log(`   User: ${config.user}`);
console.log(`   Database: ${config.database}`);
console.log('');

const pool = new Pool(config);

async function testConnection() {
  try {
    console.log('⏳ Attempting to connect...');
    const client = await pool.connect();
    console.log('✅ Connection successful!\n');

    console.log('📊 Running test query...');
    const result = await client.query('SELECT NOW() as time, version() as version');
    console.log('✅ Query successful!');
    console.log(`   Time: ${result.rows[0].time}`);
    console.log(`   PostgreSQL: ${result.rows[0].version.split(',')[0]}\n`);

    console.log('📋 Checking tables...');
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    if (tables.rows.length > 0) {
      console.log(`✅ Found ${tables.rows.length} tables:`);
      tables.rows.forEach(row => console.log(`   - ${row.table_name}`));
    } else {
      console.log('⚠️  No tables found in database');
    }

    client.release();
    await pool.end();
    
    console.log('\n✅ Database connection test PASSED!');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Database connection test FAILED!');
    console.error(`   Error: ${error.message}`);
    console.error(`   Code: ${error.code || 'N/A'}`);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('\n💡 Possible issues:');
      console.error('   - Database server is not running');
      console.error('   - Wrong host or port');
      console.error('   - Firewall blocking connection');
    } else if (error.code === 'ETIMEDOUT') {
      console.error('\n💡 Possible issues:');
      console.error('   - Network timeout (server unreachable)');
      console.error('   - Firewall blocking connection');
      console.error('   - Wrong host address');
    } else if (error.code === '28P01') {
      console.error('\n💡 Possible issues:');
      console.error('   - Wrong username or password');
      console.error('   - User does not have access to database');
    }
    
    await pool.end();
    process.exit(1);
  }
}

testConnection();
