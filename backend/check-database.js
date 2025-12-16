import { query } from './src/config/database.js';
import dotenv from 'dotenv';

dotenv.config();

console.log('🔍 Checking PostgreSQL Database...\n');

async function checkDatabase() {
  try {
    // Test connection
    console.log('1️⃣  Testing database connection...');
    await query('SELECT NOW()');
    console.log('✅ Database connection successful!\n');

    // Check tables
    console.log('2️⃣  Checking tables...');
    const tables = await query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    if (tables.rows.length === 0) {
      console.log('❌ NO TABLES FOUND!');
      console.log('   Run migrations: node migrations/run-migrations.js\n');
      process.exit(1);
    }
    
    console.log(`✅ Found ${tables.rows.length} tables:`);
    tables.rows.forEach(row => console.log(`   - ${row.table_name}`));
    console.log('');

    // Check users
    console.log('3️⃣  Checking users...');
    const users = await query('SELECT COUNT(*) as count FROM users');
    console.log(`✅ Users in database: ${users.rows[0].count}\n`);

    // Check clinics
    console.log('4️⃣  Checking clinics...');
    const clinics = await query('SELECT COUNT(*) as count FROM clinics');
    console.log(`✅ Clinics in database: ${clinics.rows[0].count}\n`);

    // Check users without clinic
    console.log('5️⃣  Checking users without clinics...');
    const usersWithoutClinic = await query(`
      SELECT id, email, full_name, role 
      FROM users 
      WHERE clinic_id IS NULL
    `);
    
    if (usersWithoutClinic.rows.length > 0) {
      console.log(`⚠️  Found ${usersWithoutClinic.rows.length} users without clinic:`);
      usersWithoutClinic.rows.forEach(user => {
        console.log(`   - ${user.email} (${user.role}) - ID: ${user.id}`);
      });
      console.log('   These users won\'t be able to access any data!\n');
    } else {
      console.log('✅ All users have clinics\n');
    }

    // Summary
    console.log('📊 SUMMARY');
    console.log('==================');
    console.log(`Tables: ${tables.rows.length}`);
    console.log(`Users: ${users.rows[0].count}`);
    console.log(`Clinics: ${clinics.rows[0].count}`);
    console.log(`Users without clinic: ${usersWithoutClinic.rows.length}`);
    console.log('');

    if (usersWithoutClinic.rows.length > 0) {
      console.log('⚠️  ACTION REQUIRED: Create clinics for users without clinic_id');
      console.log('   Or run: node migrations/create-missing-clinics.js');
    } else {
      console.log('✅ Database looks good!');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Database check failed:',error.message);
    console.error('\n💡 Make sure:');
    console.error('   1. PostgreSQL is running');
    console.error('   2. Database "clinic_db" exists');
    console.error('   3. .env file is configured correctly');
    console.error('   4. Migrations have been run');
    process.exit(1);
  }
}

checkDatabase();
