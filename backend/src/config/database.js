/**
 * PostgreSQL Database Configuration
 */

import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';

dotenv.config();

// Database pool configuration
const poolConfig = {
  connectionString: process.env.DATABASE_URL,
  
  // Connection pool settings
  max: 20, // Maximum number of connections in pool
  min: 5,  // Minimum number of connections in pool
  idleTimeoutMillis: 30000, // Close idle connections after 30 seconds
  connectionTimeoutMillis: 10000, // Wait 10 seconds for connection
  
  // SSL configuration for production
  ssl: process.env.NODE_ENV === 'production' 
    ? { rejectUnauthorized: false } 
    : false
};

// Create pool instance
const pool = new Pool(poolConfig);

// Pool error handler
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle database client', err);
  process.exit(-1);
});

// Pool connection handler
pool.on('connect', (client) => {
  console.log('New database connection established');
});

/**
 * Execute a query
 * @param {string} text - SQL query
 * @param {Array} params - Query parameters
 * @returns {Promise} Query result
 */
export async function query(text, params) {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    
    if (process.env.NODE_ENV !== 'production') {
      console.log('Executed query', { text, duration, rows: result.rowCount });
    }
    
    return result;
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
}

/**
 * Get a client from the pool for transactions
 * @returns {Promise} Database client
 */
export async function getClient() {
  const client = await pool.connect();
  return client;
}

/**
 * Test database connection
 * @returns {Promise<boolean>} Connection status
 */
export async function testConnection() {
  try {
    const result = await pool.query('SELECT NOW()');
    console.log('✓ Database connection successful:', result.rows[0].now);
    return true;
  } catch (error) {
    console.error('✗ Database connection failed:', error.message);
    return false;
  }
}

/**
 * Close all connections
 */
export async function closePool() {
  await pool.end();
  console.log('Database pool closed');
}

/**
 * Transaction helper
 * @param {Function} callback - Transaction operations
 * @returns {Promise} Transaction result
 */
export async function transaction(callback) {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Export pool for direct access if needed
export { pool };

// Default export
export default {
  query,
  getClient,
  testConnection,
  closePool,
  transaction,
  pool
};
