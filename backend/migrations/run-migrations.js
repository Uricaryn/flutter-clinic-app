import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { pool, closePool } from '../src/config/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function runMigration() {
  console.log('🚀 Starting database migration...\n');

  try {
    // Read the SQL migration file
    const sqlFilePath = join(__dirname, '001_initial_schema.sql');
    const sql = readFileSync(sqlFilePath, 'utf-8');

    console.log('📄 Executing migration: 001_initial_schema.sql');

    // Execute the migration
    await pool.query(sql);

    console.log('\n✅ Migration completed successfully!');
    console.log('\n📊 Database schema has been created with the following tables:');
    console.log('   - clinics');
    console.log('   - users');
    console.log('   - patients');
    console.log('   - procedures');
    console.log('   - stock_items');
    console.log('   - appointments');
    console.log('   - appointment_stock_items');
    console.log('   - procedure_materials');
    console.log('   - expenses');
    console.log('   - operators');
    console.log('\n✨ All indexes and triggers have been created.');

    // Close the pool
    await closePool();
    console.log('\n🎉 Setup complete! Ready to start the server.');
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
runMigration();

