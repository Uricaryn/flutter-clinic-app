import { testConnection } from './src/config/database.js';
import pool from './src/config/database.js';

console.log('🔌 Testing PostgreSQL Database Connection...\n');

testConnection()
  .then(async (success) => {
    if (success) {
      console.log('\n✅ Database connection test successful!\n');
      
      // Test a simple query
      try {
        const result = await pool.query('SELECT version()');
        console.log('📊 PostgreSQL Version:');
        console.log(result.rows[0].version);
        console.log('\n✨ Your database is ready to use!');
      } catch (error) {
        console.error('❌ Error querying database:', error.message);
      }
    } else {
      console.log('\n❌ Database connection test failed!');
      console.log('\n📝 Troubleshooting steps:');
      console.log('1. Make sure PostgreSQL is installed and running');
      console.log('2. Check your .env file has the correct database credentials');
      console.log('3. Verify the database "clinic_db" exists');
      console.log('4. Run: psql -U postgres -c "CREATE DATABASE clinic_db;"');
    }
    
    await pool.end();
    process.exit(success ? 0 : 1);
  })
  .catch((error) => {
    console.error('❌ Unexpected error:', error);
    pool.end();
    process.exit(1);
  });
