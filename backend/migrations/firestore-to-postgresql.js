/**
 * Firestore to PostgreSQL Data Migration Script
 * 
 * This script migrates all data from Firebase Firestore to PostgreSQL.
 * It handles data transformation, maintains relationships, and provides
 * progress tracking.
 * 
 * Usage:
 *   node migrations/firestore-to-postgresql.js
 * 
 * Prerequisites:
 *   1. Firebase Admin SDK credentials (serviceAccountKey.json)
 *   2. PostgreSQL database created and schema migrated
 *   3. .env file configured with DATABASE_URL
 */

import admin from 'firebase-admin';
import pg from 'pg';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

const { Pool } = pg;

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, '..', 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ Error: serviceAccountKey.json not found!');
  console.log('Please download it from Firebase Console:');
  console.log('1. Go to Firebase Console > Project Settings > Service Accounts');
  console.log('2. Click "Generate New Private Key"');
  console.log(`3. Save as: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Migration statistics
const stats = {
  clinics: { total: 0, success: 0, failed: 0 },
  users: { total: 0, success: 0, failed: 0 },
  patients: { total: 0, success: 0, failed: 0 },
  procedures: { total: 0, success: 0, failed: 0 },
  stock_items: { total: 0, success: 0, failed: 0 },
  procedure_materials: { total: 0, success: 0, failed: 0 },
  operators: { total: 0, success: 0, failed: 0 },
  appointments: { total: 0, success: 0, failed: 0 },
  appointment_stock_items: { total: 0, success: 0, failed: 0 },
  expenses: { total: 0, success: 0, failed: 0 },
};

// Mapping of Firestore IDs to PostgreSQL UUIDs
const idMap = new Map();

/**
 * Convert Firestore Timestamp to PostgreSQL timestamp
 */
function convertTimestamp(timestamp) {
  if (!timestamp) return null;
  if (timestamp.toDate) {
    return timestamp.toDate().toISOString();
  }
  return timestamp;
}

/**
 * Migrate clinics collection
 */
async function migrateClinics() {
  console.log('\n📦 Migrating clinics...');
  
  const snapshot = await db.collection('clinics').get();
  stats.clinics.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      
      const result = await pool.query(
        `INSERT INTO clinics (
          name, specialization, address, phone, email,
          phone_country_code, phone_number, is_active,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING id`,
        [
          data.name || '',
          data.specialization || '',
          data.address || '',
          data.phone || '',
          data.email || '',
          data.clinicPhoneCountryCode || '+90',
          data.clinicPhoneNumber || '',
          data.isActive !== false,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      // Store ID mapping
      idMap.set(`clinic_${doc.id}`, result.rows[0].id);
      stats.clinics.success++;
      console.log(`  ✅ Clinic: ${data.name} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.clinics.failed++;
      console.error(`  ❌ Failed to migrate clinic ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate users collection
 */
async function migrateUsers() {
  console.log('\n👥 Migrating users...');
  
  const snapshot = await db.collection('users').get();
  stats.users.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      
      // Get clinic UUID if exists
      const clinicId = data.clinicId ? idMap.get(`clinic_${data.clinicId}`) : null;

      const result = await pool.query(
        `INSERT INTO users (
          email, password_hash, full_name, phone, avatar, role,
          clinic_id, is_active, email_verified,
          created_at, updated_at, last_login, last_logout
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        RETURNING id`,
        [
          data.email || '',
          'MIGRATED_' + Math.random().toString(36), // Temporary password hash
          data.fullName || data.name || '',
          data.phone || null,
          data.avatar || null,
          data.role || 'patient',
          clinicId,
          data.isActive !== false,
          data.emailVerified || false,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
          convertTimestamp(data.lastLogin),
          convertTimestamp(data.lastLogout),
        ]
      );

      // Update owner_id in clinics if this user is the owner
      if (clinicId) {
        await pool.query(
          'UPDATE clinics SET owner_id = $1 WHERE id = $2',
          [result.rows[0].id, clinicId]
        );
      }

      idMap.set(`user_${doc.id}`, result.rows[0].id);
      stats.users.success++;
      console.log(`  ✅ User: ${data.email} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.users.failed++;
      console.error(`  ❌ Failed to migrate user ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate patients collection
 */
async function migratePatients() {
  console.log('\n🏥 Migrating patients...');
  
  const snapshot = await db.collection('patients').get();
  stats.patients.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);

      if (!clinicId) {
        throw new Error(`Clinic not found for patient ${doc.id}`);
      }

      const result = await pool.query(
        `INSERT INTO patients (
          clinic_id, full_name, email, phone, address,
          date_of_birth, gender, notes,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING id`,
        [
          clinicId,
          data.fullName || '',
          data.email || '',
          data.phone || '',
          data.address || '',
          convertTimestamp(data.dateOfBirth),
          data.gender || '',
          data.notes || '',
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      idMap.set(`patient_${doc.id}`, result.rows[0].id);
      stats.patients.success++;
      console.log(`  ✅ Patient: ${data.fullName} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.patients.failed++;
      console.error(`  ❌ Failed to migrate patient ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate procedures collection
 */
async function migrateProcedures() {
  console.log('\n💉 Migrating procedures...');
  
  const snapshot = await db.collection('procedures').get();
  stats.procedures.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);

      if (!clinicId) {
        throw new Error(`Clinic not found for procedure ${doc.id}`);
      }

      const result = await pool.query(
        `INSERT INTO procedures (
          clinic_id, name, description, price, duration_minutes, is_active,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id`,
        [
          clinicId,
          data.name || '',
          data.description || '',
          data.price || 0,
          data.durationMinutes || 0,
          data.isActive !== false,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      idMap.set(`procedure_${doc.id}`, result.rows[0].id);
      
      // Migrate procedure materials
      if (data.materials && Array.isArray(data.materials)) {
        for (const material of data.materials) {
          const stockItemId = idMap.get(`stock_item_${material.stockItemId}`);
          if (stockItemId) {
            await pool.query(
              `INSERT INTO procedure_materials (procedure_id, stock_item_id, quantity, unit)
               VALUES ($1, $2, $3, $4)`,
              [result.rows[0].id, stockItemId, material.quantity, material.unit]
            );
            stats.procedure_materials.success++;
          }
        }
      }

      stats.procedures.success++;
      console.log(`  ✅ Procedure: ${data.name} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.procedures.failed++;
      console.error(`  ❌ Failed to migrate procedure ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate stock_items collection
 */
async function migrateStockItems() {
  console.log('\n📦 Migrating stock items...');
  
  const snapshot = await db.collection('stock_items').get();
  stats.stock_items.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);

      if (!clinicId) {
        throw new Error(`Clinic not found for stock item ${doc.id}`);
      }

      const result = await pool.query(
        `INSERT INTO stock_items (
          clinic_id, name, description, price, cost, quantity, unit,
          minimum_quantity, last_restocked,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING id`,
        [
          clinicId,
          data.name || '',
          data.description || '',
          data.price || 0,
          data.cost || 0,
          data.quantity || 0,
          data.unit || '',
          data.minimumQuantity || 0,
          convertTimestamp(data.lastRestocked) || new Date().toISOString(),
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      idMap.set(`stock_item_${doc.id}`, result.rows[0].id);
      stats.stock_items.success++;
      console.log(`  ✅ Stock Item: ${data.name} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.stock_items.failed++;
      console.error(`  ❌ Failed to migrate stock item ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate operators collection
 */
async function migrateOperators() {
  console.log('\n👨‍⚕️ Migrating operators...');
  
  const snapshot = await db.collection('operators').get();
  if (snapshot.empty) {
    console.log('  ℹ️  No operators to migrate');
    return;
  }

  stats.operators.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);

      if (!clinicId) {
        throw new Error(`Clinic not found for operator ${doc.id}`);
      }

      const result = await pool.query(
        `INSERT INTO operators (
          clinic_id, name, email, phone, role, is_active,
          is_email_verified, temporary_password,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING id`,
        [
          clinicId,
          data.name || '',
          data.email || '',
          data.phone || '',
          data.role || '',
          data.isActive !== false,
          data.isEmailVerified || false,
          data.temporaryPassword || false,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      idMap.set(`operator_${doc.id}`, result.rows[0].id);
      stats.operators.success++;
      console.log(`  ✅ Operator: ${data.name} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.operators.failed++;
      console.error(`  ❌ Failed to migrate operator ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate appointments collection
 */
async function migrateAppointments() {
  console.log('\n📅 Migrating appointments...');
  
  const snapshot = await db.collection('appointments').get();
  stats.appointments.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);
      const patientId = idMap.get(`patient_${data.patientId}`);
      const procedureId = idMap.get(`procedure_${data.procedureId}`);
      const operatorId = idMap.get(`user_${data.operatorId}`);

      if (!clinicId) {
        throw new Error('Clinic not found');
      }

      const result = await pool.query(
        `INSERT INTO appointments (
          clinic_id, patient_id, patient_name, patient_phone,
          procedure_id, procedure_name, operator_id, operator_name,
          date_time, status, notes,
          payment_amount, payment_date, payment_method, payment_note,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
        RETURNING id`,
        [
          clinicId,
          patientId || null,
          data.patientName || '',
          data.patientPhone || '',
          procedureId || null,
          data.procedureName || '',
          operatorId || null,
          data.operatorName || '',
          convertTimestamp(data.dateTime),
          data.status || 'scheduled',
          data.notes || null,
          data.paymentAmount || null,
          convertTimestamp(data.paymentDate),
          data.paymentMethod || null,
          data.paymentNote || null,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      // Migrate used stock items
      if (data.usedStockItems && Array.isArray(data.usedStockItems)) {
        for (const item of data.usedStockItems) {
          const stockItemId = idMap.get(`stock_item_${item.id}`);
          await pool.query(
            `INSERT INTO appointment_stock_items (
              appointment_id, stock_item_id, stock_item_name,
              quantity, unit, cost
            ) VALUES ($1, $2, $3, $4, $5, $6)`,
            [
              result.rows[0].id,
              stockItemId || null,
              item.name,
              item.quantity,
              item.unit,
              item.cost || 0,
            ]
          );
          stats.appointment_stock_items.success++;
        }
      }

      idMap.set(`appointment_${doc.id}`, result.rows[0].id);
      stats.appointments.success++;
      console.log(`  ✅ Appointment: ${data.patientName} on ${convertTimestamp(data.dateTime)} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.appointments.failed++;
      console.error(`  ❌ Failed to migrate appointment ${doc.id}:`, err.message);
    }
  }
}

/**
 * Migrate expenses collection
 */
async function migrateExpenses() {
  console.log('\n💰 Migrating expenses...');
  
  const snapshot = await db.collection('expenses').get();
  if (snapshot.empty) {
    console.log('  ℹ️  No expenses to migrate');
    return;
  }

  stats.expenses.total = snapshot.size;

  for (const doc of snapshot.docs) {
    try {
      const data = doc.data();
      const clinicId = idMap.get(`clinic_${data.clinicId}`);

      if (!clinicId) {
        throw new Error('Clinic not found');
      }

      const result = await pool.query(
        `INSERT INTO expenses (
          clinic_id, title, description, amount, category,
          date, invoice_number,
          created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING id`,
        [
          clinicId,
          data.title || '',
          data.description || '',
          data.amount || 0,
          data.category || '',
          convertTimestamp(data.date),
          data.invoiceNumber || null,
          convertTimestamp(data.createdAt) || new Date().toISOString(),
          convertTimestamp(data.updatedAt) || new Date().toISOString(),
        ]
      );

      idMap.set(`expense_${doc.id}`, result.rows[0].id);
      stats.expenses.success++;
      console.log(`  ✅ Expense: ${data.title} (${doc.id} -> ${result.rows[0].id})`);
    } catch (err) {
      stats.expenses.failed++;
      console.error(`  ❌ Failed to migrate expense ${doc.id}:`, err.message);
    }
  }
}

/**
 * Print migration summary
 */
function printSummary() {
  console.log('\n');
  console.log('═══════════════════════════════════════════════════');
  console.log('📊 MIGRATION SUMMARY');
  console.log('═══════════════════════════════════════════════════');
  console.log('');

  Object.entries(stats).forEach(([collection, count]) => {
    const successRate = count.total > 0
      ? ((count.success / count.total) * 100).toFixed(1)
      : '0.0';
    
    console.log(`${collection.toUpperCase()}:`);
    console.log(`  Total: ${count.total}`);
    console.log(`  ✅ Success: ${count.success}`);
    console.log(`  ❌ Failed: ${count.failed}`);
    console.log(`  Success Rate: ${successRate}%`);
    console.log('');
  });

  const totalSuccess = Object.values(stats).reduce((sum, s) => sum + s.success, 0);
  const totalRecords = Object.values(stats).reduce((sum, s) => sum + s.total, 0);
  const overallRate = totalRecords > 0
    ? ((totalSuccess / totalRecords) * 100).toFixed(1)
    : '0.0';

  console.log('═══════════════════════════════════════════════════');
  console.log(`OVERALL: ${totalSuccess}/${totalRecords} records migrated (${overallRate}%)`);
  console.log('═══════════════════════════════════════════════════');
  console.log('');
}

/**
 * Main migration function
 */
async function runMigration() {
  console.log('🚀 Starting Firestore to PostgreSQL migration...');
  console.log('');

  try {
    // Test database connection
    await pool.query('SELECT NOW()');
    console.log('✅ PostgreSQL connection successful');

    // Confirm migration
    console.log('');
    console.log('⚠️  WARNING: This will import data into PostgreSQL');
    console.log('⚠️  Make sure the database schema is created first!');
    console.log('');
    console.log('Starting migration in 3 seconds...');
    await new Promise(resolve => setTimeout(resolve, 3000));

    // Migration order (respects foreign key dependencies)
    await migrateClinics();
    await migrateUsers();
    await migratePatients();
    await migrateStockItems();
    await migrateProcedures(); // After stock items for procedure_materials
    await migrateOperators();
    await migrateAppointments(); // Last, depends on everything
    await migrateExpenses();

    // Print summary
    printSummary();

    // Save ID mapping to file for reference
    const mappingFile = path.join(__dirname, 'id-mapping.json');
    const mapping = Object.fromEntries(idMap);
    fs.writeFileSync(mappingFile, JSON.stringify(mapping, null, 2));
    console.log(`💾 ID mapping saved to: ${mappingFile}`);

    console.log('');
    console.log('✅ Migration completed successfully!');
    console.log('');
    console.log('⚠️  IMPORTANT: Users will need to reset their passwords!');
    console.log('   Passwords were not migrated for security reasons.');
    console.log('');

  } catch (err) {
    console.error('❌ Migration failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
    console.log('Database connection closed.');
  }
}

// Run migration
runMigration().catch(console.error);
