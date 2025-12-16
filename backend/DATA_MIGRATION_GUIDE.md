# Firestore to PostgreSQL Data Migration Guide

## Overview

This guide walks you through migrating your existing Firestore data to PostgreSQL. The migration is designed to be safe, reversible, and maintain data integrity.

## Prerequisites

### 1. Firebase Service Account Key

Download your Firebase service account credentials:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (⚙️) > **Service Accounts**
4. Click **"Generate New Private Key"**
5. Save the file as `backend/serviceAccountKey.json`

**Security:** Never commit this file to git! It's already in `.gitignore`.

### 2. PostgreSQL Database Ready

Ensure your PostgreSQL database is created and schema is migrated:

```bash
cd backend

# Create database
createdb clinic_db

# Or using psql
psql -U postgres
CREATE DATABASE clinic_db;
\q

# Run schema migrations
node migrations/run-migrations.js
```

### 3. Environment Variables

Make sure your `.env` file is configured:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/clinic_db
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=another-secret-here
REFRESH_TOKEN_EXPIRATION=30d
PORT=3000
NODE_ENV=development
```

## Migration Process

### Step 1: Backup Everything

**CRITICAL:** Always backup before migration!

```bash
# 1. Export Firestore data (Firebase Console)
# Go to: Firestore Database > Import/Export > Export
# Or use gcloud CLI:
gcloud firestore export gs://YOUR_BUCKET/firestore-backup-$(date +%Y%m%d)

# 2. Create PostgreSQL backup point
pg_dump clinic_db > clinic_db_pre_migration.sql

# 3. Create Git commit
cd ..
git add .
git commit -m "chore: pre-migration checkpoint"
git tag pre-migration-$(date +%Y%m%d)
```

### Step 2: Prepare Migration

```bash
cd backend

# Install dependencies if not already done
npm install firebase-admin

# Verify serviceAccountKey.json exists
ls serviceAccountKey.json

# Test database connection
npm run test

# Verify schema is up to date
psql $DATABASE_URL -f migrations/verify-schema.sql
```

### Step 3: Run Migration

```bash
# Dry run first (review what will be migrated)
# The script shows what it will migrate before starting

# Run migration
node migrations/firestore-to-postgresql.js

# The script will:
# - Connect to both Firestore and PostgreSQL
# - Migrate data in dependency order
# - Show progress for each collection
# - Generate detailed logs
# - Save ID mapping to id-mapping.json
```

### Step 4: Verify Migration

```bash
# Check PostgreSQL data
psql $DATABASE_URL

# Count records
SELECT 
  (SELECT COUNT(*) FROM clinics) as clinics,
  (SELECT COUNT(*) FROM users) as users,
  (SELECT COUNT(*) FROM patients) as patients,
  (SELECT COUNT(*) FROM procedures) as procedures,
  (SELECT COUNT(*) FROM stock_items) as stock_items,
  (SELECT COUNT(*) FROM appointments) as appointments,
  (SELECT COUNT(*) FROM operators) as operators,
  (SELECT COUNT(*) FROM expenses) as expenses;

# Check relationships
SELECT 
  p.full_name, 
  c.name as clinic_name
FROM patients p
JOIN clinics c ON p.clinic_id = c.id
LIMIT 5;
```

## Migration Order

The script migrates collections in this order to respect foreign key relationships:

1. **Clinics** (no dependencies)
2. **Users** (references clinics)
3. **Patients** (references clinics)
4. **Stock Items** (references clinics)
5. **Procedures** (references clinics)
6. **Procedure Materials** (references procedures & stock_items)
7. **Operators** (references clinics)
8. **Appointments** (references patients, procedures, operators)
9. **Appointment Stock Items** (references appointments & stock_items)
10. **Expenses** (references clinics)

## Data Transformations

### Firestore → PostgreSQL Mappings

| Firestore | PostgreSQL | Notes |
|-----------|-----------|-------|
| Document ID | UUID | New UUIDs generated |
| Timestamp | TIMESTAMP | Converted to ISO-8601 |
| Reference | UUID foreign key | Using ID mapping |
| Array | ARRAY or junction table | Normalized |
| Map | JSONB or separate table | Structured |

### Special Handling

#### User Passwords

**Important:** Passwords are NOT migrated!

- Firebase uses its own password hashing
- PostgreSQL users will need to reset passwords
- Migration script generates placeholder hashes
- Send password reset emails after migration

#### Timestamps

```javascript
// Firestore Timestamp
{ createdAt: Timestamp(seconds: 1639234567, nanoseconds: 0) }

// PostgreSQL TIMESTAMP
{ created_at: '2021-12-11T12:34:56.000Z' }
```

#### ID Conversion

```javascript
// Firestore auto-generated IDs
{ id: 'abc123xyz' }

// PostgreSQL UUIDs
{ id: '550e8400-e29b-41d4-a716-446655440000' }
```

## Post-Migration Tasks

### 1. User Password Reset

All users need new passwords. Two options:

**Option A: Bulk Password Reset Email**

```javascript
// Create a script to send reset emails
const users = await pool.query('SELECT email FROM users WHERE email_verified = true');

for (const user of users.rows) {
  // Send password reset email via your email service
  await sendPasswordResetEmail(user.email);
}
```

**Option B: Temporary Passwords**

```javascript
// Generate temporary passwords
const bcrypt = require('bcrypt');

for (const user of users.rows) {
  const tempPassword = generateRandomPassword();
  const hash = await bcrypt.hash(tempPassword, 10);
  
  await pool.query(
    'UPDATE users SET password_hash = $1, temporary_password = true WHERE id = $2',
    [hash, user.id]
  );
  
  // Email user their temporary password
  await emailTemporaryPassword(user.email, tempPassword);
}
```

### 2. Update App Configuration

Switch the app to PostgreSQL mode:

```dart
// lib/core/config/app_mode.dart
static const DatabaseMode _defaultMode = DatabaseMode.postgresql; // Changed!
```

Or use build-time flag:

```bash
flutter build apk --dart-define=DB_MODE=postgresql
```

### 3. Verify App Functionality

```bash
# Start backend
cd backend
npm start

# In another terminal, run Flutter app
cd ..
flutter run --dart-define=DB_MODE=postgresql

# Test all features:
# - Login (with reset password)
# - View appointments
# - Create/edit records
# - Realtime updates
# - Search functionality
```

### 4. Monitor for Issues

```bash
# Backend logs
cd backend
npm start | tee migration-test.log

# Check for errors
grep -i error migration-test.log
```

## Rollback Procedure

If something goes wrong, you can rollback:

### Rollback Step 1: Switch App Back to Firebase

```dart
// lib/core/config/app_mode.dart
static const DatabaseMode _defaultMode = DatabaseMode.firebase; // Rollback!
```

Or:

```bash
flutter run --dart-define=DB_MODE=firebase
```

### Rollback Step 2: Restore PostgreSQL Database (Optional)

If you want to retry migration:

```bash
# Drop and recreate database
dropdb clinic_db
createdb clinic_db

# Restore from backup
psql clinic_db < clinic_db_pre_migration.sql

# Or restore empty schema
cd backend
node migrations/run-migrations.js
```

### Rollback Step 3: Restore Firestore (If Needed)

If you exported Firestore data:

```bash
# Import from export
gcloud firestore import gs://YOUR_BUCKET/firestore-backup-YYYYMMDD
```

## Troubleshooting

### Error: "Clinic not found for patient X"

**Cause:** Foreign key dependency not found in ID mapping

**Fix:**
1. Ensure clinics were migrated first
2. Check if the clinic ID exists in Firestore
3. Verify clinic migration didn't fail

### Error: "serviceAccountKey.json not found"

**Fix:**
1. Download from Firebase Console
2. Save to `backend/serviceAccountKey.json`
3. Verify file permissions

### Error: "Database connection failed"

**Fix:**
1. Check PostgreSQL is running
2. Verify DATABASE_URL in .env
3. Test connection: `psql $DATABASE_URL`

### Partial Migration

If migration fails partway through:

```sql
-- Check what was migrated
SELECT COUNT(*) FROM clinics;
SELECT COUNT(*) FROM users;
-- etc...

-- If you need to start over
TRUNCATE TABLE 
  appointment_stock_items,
  appointments,
  procedure_materials,
  operators,
  expenses,
  stock_items,
  procedures,
  patients,
  users,
  clinics
CASCADE;

-- Then re-run migration
node migrations/firestore-to-postgresql.js
```

## Advanced Options

### Selective Migration

Edit the script to migrate only specific collections:

```javascript
// In firestore-to-postgresql.js
async function runMigration() {
  // Comment out collections you don't want to migrate
  await migrateClinics();
  // await migrateUsers();  // Skip users
  await migratePatients();
  // ... etc
}
```

### Data Transformation

Add custom transformations in the migration script:

```javascript
// Example: Transform phone numbers
const phone = data.phone ? formatPhoneNumber(data.phone) : null;

// Example: Set default values
const isActive = data.isActive !== undefined ? data.isActive : true;
```

### Progress Tracking

The script automatically tracks progress. To save logs:

```bash
node migrations/firestore-to-postgresql.js | tee migration-log.txt
```

## Post-Migration Checklist

After successful migration:

- [ ] All collections migrated successfully
- [ ] Record counts match between Firestore and PostgreSQL
- [ ] Relationships verified (foreign keys work)
- [ ] Sample queries return expected data
- [ ] App runs in PostgreSQL mode
- [ ] Users can login (after password reset)
- [ ] Realtime updates work
- [ ] All features tested
- [ ] Production deployment planned
- [ ] Firestore export saved for rollback
- [ ] Team informed of password reset requirement

## Security Notes

1. **serviceAccountKey.json**
   - Contains full admin access to Firebase
   - Never commit to version control
   - Delete after migration if not needed
   - Store securely if keeping

2. **ID Mapping File**
   - Contains all Firestore ID → PostgreSQL UUID mappings
   - Useful for debugging
   - Safe to delete after verification

3. **Password Migration**
   - Passwords cannot be migrated
   - Users must reset passwords
   - Use secure password reset flow
   - Consider 2FA for sensitive accounts

## Support

If you encounter issues:

1. Check the migration logs
2. Review `id-mapping.json` for ID conversions
3. Verify schema with `migrations/verify-schema.sql`
4. Test database connection
5. Check Firestore permissions

## Next Steps

After successful migration:

1. **Update main branch** when ready for production
2. **Deploy backend** to cloud provider
3. **Update Flutter app** to use PostgreSQL by default
4. **Monitor** for any issues
5. **Keep Firebase** as backup for a period
6. **Eventually deprecate** Firebase after stable period
