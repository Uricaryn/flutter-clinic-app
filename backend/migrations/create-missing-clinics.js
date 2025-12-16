import { query } from '../src/config/database.js';
import dotenv from 'dotenv';

dotenv.config();

console.log('🏥 Creating missing clinics for users...\n');

async function createMissingClinics() {
  try {
    // Find users without clinics
    const usersWithoutClinic = await query(`
      SELECT id, email, full_name, role 
      FROM users 
      WHERE clinic_id IS NULL
    `);

    if (usersWithoutClinic.rows.length === 0) {
      console.log('✅ All users already have clinics!');
      process.exit(0);
    }

    console.log(`Found ${usersWithoutClinic.rows.length} users without clinics:\n`);

    for (const user of usersWithoutClinic.rows) {
      console.log(`Processing: ${user.email} (${user.role})`);

      // Create clinic for user
      const clinicName = `${user.full_name}'s Clinic`;
      
      const clinicResult = await query(`
        INSERT INTO clinics (name, owner_id, is_active, created_at, updated_at)
        VALUES ($1, $2, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING id, name
      `, [clinicName, user.id]);

      const clinic = clinicResult.rows[0];
      console.log(`  ✅ Created clinic: "${clinic.name}" (ID: ${clinic.id})`);

      // Update user with clinic_id
      await query(`
        UPDATE users 
        SET clinic_id = $1, updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
      `, [clinic.id, user.id]);

      console.log(`  ✅ Updated user with clinic_id\n`);
    }

    // Summary
    const clinicsCount = await query('SELECT COUNT(*) as count FROM clinics');
    const usersCount = await query('SELECT COUNT(*) as count FROM users WHERE clinic_id IS NOT NULL');

    console.log('📊 SUMMARY');
    console.log('==================');
    console.log(`Total Clinics: ${clinicsCount.rows[0].count}`);
    console.log(`Users with clinics: ${usersCount.rows[0].count}`);
    console.log('');
    console.log('✅ All users now have clinics!');
    console.log('🎉 You can now use the app!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Failed to create clinics:', error.message);
    process.exit(1);
  }
}

createMissingClinics();
