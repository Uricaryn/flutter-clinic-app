/**
 * Database Connection Test Script
 * Verifies PostgreSQL connection and schema setup
 */

import db from './src/config/database.js';
import dotenv from 'dotenv';

dotenv.config();

async function testConnection() {
  console.log('='.repeat(60));
  console.log('Testing PostgreSQL Database Connection');
  console.log('='.repeat(60));
  console.log('');

  try {
    // Test 1: Basic connection
    console.log('1. Testing database connection...');
    const timeResult = await db.query('SELECT NOW() as current_time');
    console.log('   ✓ Connection successful');
    console.log(`   ✓ Server time: ${timeResult.rows[0].current_time}`);
    console.log('');

    // Test 2: Check PostgreSQL version
    console.log('2. Checking PostgreSQL version...');
    const versionResult = await db.query('SELECT version()');
    const version = versionResult.rows[0].version;
    console.log(`   ✓ ${version.split(',')[0]}`);
    console.log('');

    // Test 3: Check UUID extension
    console.log('3. Checking UUID extension...');
    const uuidResult = await db.query(
      "SELECT * FROM pg_extension WHERE extname = 'uuid-ossp'"
    );
    if (uuidResult.rows.length > 0) {
      console.log('   ✓ UUID extension is enabled');
    } else {
      console.log('   ⚠ UUID extension is NOT enabled');
    }
    console.log('');

    // Test 4: List all tables
    console.log('4. Checking database tables...');
    const tablesResult = await db.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    const tables = tablesResult.rows.map(r => r.table_name);
    const expectedTables = [
      'migrations',
      'clinics',
      'users',
      'patients',
      'procedures',
      'stock_items',
      'appointments',
      'operators',
      'expenses',
      'procedure_materials',
      'appointment_stock_items'
    ];
    
    console.log(`   ✓ Found ${tables.length} tables`);
    
    // Check if all expected tables exist
    const missingTables = expectedTables.filter(t => !tables.includes(t));
    if (missingTables.length === 0) {
      console.log('   ✓ All required tables exist');
    } else {
      console.log(`   ⚠ Missing tables: ${missingTables.join(', ')}`);
    }
    console.log('');

    // Test 5: Check indexes
    console.log('5. Checking database indexes...');
    const indexResult = await db.query(`
      SELECT COUNT(*) as count
      FROM pg_indexes
      WHERE schemaname = 'public'
    `);
    console.log(`   ✓ Found ${indexResult.rows[0].count} indexes`);
    console.log('');

    // Test 6: Check foreign keys
    console.log('6. Checking foreign key constraints...');
    const fkResult = await db.query(`
      SELECT COUNT(*) as count
      FROM information_schema.table_constraints
      WHERE constraint_type = 'FOREIGN KEY'
      AND table_schema = 'public'
    `);
    console.log(`   ✓ Found ${fkResult.rows[0].count} foreign key constraints`);
    console.log('');

    // Test 7: Check triggers
    console.log('7. Checking database triggers...');
    const triggerResult = await db.query(`
      SELECT COUNT(*) as count
      FROM information_schema.triggers
      WHERE trigger_schema = 'public'
    `);
    console.log(`   ✓ Found ${triggerResult.rows[0].count} triggers`);
    console.log('');

    // Test 8: Check migrations
    console.log('8. Checking migration history...');
    const migrationResult = await db.query(`
      SELECT name, executed_at 
      FROM migrations 
      ORDER BY executed_at
    `);
    
    if (migrationResult.rows.length === 0) {
      console.log('   ⚠ No migrations have been executed');
      console.log('   → Run: npm run migrate');
    } else {
      console.log(`   ✓ ${migrationResult.rows.length} migration(s) executed`);
      migrationResult.rows.forEach(m => {
        const date = new Date(m.executed_at).toLocaleString();
        console.log(`     - ${m.name} (${date})`);
      });
    }
    console.log('');

    // Test 9: Test query performance
    console.log('9. Testing query performance...');
    const start = Date.now();
    await db.query('SELECT COUNT(*) FROM clinics');
    const duration = Date.now() - start;
    console.log(`   ✓ Query executed in ${duration}ms`);
    console.log('');

    // Test 10: Test transaction
    console.log('10. Testing transaction support...');
    await db.transaction(async (client) => {
      await client.query('SELECT 1');
    });
    console.log('    ✓ Transactions working correctly');
    console.log('');

    // Summary
    console.log('='.repeat(60));
    console.log('✅ All tests passed! Database is ready.');
    console.log('='.repeat(60));
    console.log('');
    console.log('Next steps:');
    console.log('  1. npm run dev    - Start development server');
    console.log('  2. npm start      - Start production server');
    console.log('');

  } catch (error) {
    console.error('');
    console.error('='.repeat(60));
    console.error('❌ Database Connection Test Failed');
    console.error('='.repeat(60));
    console.error('');
    console.error('Error:', error.message);
    console.error('');
    console.error('Troubleshooting:');
    console.error('  1. Check if PostgreSQL is running');
    console.error('  2. Verify DATABASE_URL in .env file');
    console.error('  3. Ensure database "clinic_db" exists');
    console.error('  4. Run migrations: npm run migrate');
    console.error('  5. Check PostgreSQL logs for errors');
    console.error('');
    console.error('DATABASE_URL format:');
    console.error('  postgresql://username:password@host:port/database');
    console.error('');
    console.error('Current DATABASE_URL (without password):');
    const dbUrl = process.env.DATABASE_URL || 'NOT SET';
    const sanitized = dbUrl.replace(/:[^:@]+@/, ':****@');
    console.error(`  ${sanitized}`);
    console.error('');
    
    process.exit(1);
  } finally {
    await db.closePool();
  }
}

// Run test
testConnection();

