import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { pool, closePool } from '../src/config/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function runAuthMigration() {
  console.log('🚀 Running authentication tokens migration...\n');

  try {
    // Read the SQL migration file
    const sqlFilePath = join(__dirname, '002_add_auth_tokens.sql');
    const sql = readFileSync(sqlFilePath, 'utf-8');

    console.log('📄 Executing migration: 002_add_auth_tokens.sql');

    // Execute the migration
    await pool.query(sql);

    console.log('\n✅ Migration completed successfully!');
    console.log('\n📊 Added authentication token fields to users table:');
    console.log('   - reset_token');
    console.log('   - reset_token_expiry');
    console.log('   - verification_token');
    console.log('   - verification_token_expiry');
    console.log('\n✨ Indexes and triggers have been created.');

    // Close the pool
    await closePool();
    console.log('\n🎉 Authentication migration complete!');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Migration failed:', error.message);
    console.error('\nFull error:', error);
    try {
      await closePool();
    } catch (closeError) {
      // Ignore close errors
    }
    process.exit(1);
  }
}

// Run the migration
runAuthMigration();

