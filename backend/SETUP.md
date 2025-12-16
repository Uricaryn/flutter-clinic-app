# Quick Setup Guide - PostgreSQL Backend

This guide will help you set up the PostgreSQL backend in 5-10 minutes.

## Prerequisites Check

Before starting, make sure you have:

- [ ] Node.js installed (v16+): Run `node --version`
- [ ] PostgreSQL installed (v13+): Run `psql --version`
- [ ] npm or yarn: Run `npm --version`

## Step-by-Step Setup

### 1. Install Dependencies (1 minute)

```bash
cd backend
npm install
```

Expected output: `added XXX packages`

### 2. Install and Start PostgreSQL

#### Windows

1. Download: https://www.postgresql.org/download/windows/
2. Run installer, remember password for 'postgres' user
3. Default port: 5432
4. Verify: Open "SQL Shell (psql)" from Start menu

#### macOS

```bash
# Install
brew install postgresql@15

# Start service
brew services start postgresql@15

# Verify
psql postgres
```

#### Linux (Ubuntu/Debian)

```bash
# Install
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify
sudo -u postgres psql
```

### 3. Create Database (2 minutes)

Open PostgreSQL command line:

```bash
# Windows: Use "SQL Shell (psql)" from Start menu
# macOS/Linux: 
psql -U postgres
```

Run these commands:

```sql
-- Create database
CREATE DATABASE clinic_db;

-- Verify
\l

-- Exit
\q
```

### 4. Configure Environment (1 minute)

```bash
# Copy template
cp .env.example .env
```

Edit `.env` file (change YOUR_PASSWORD):

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/clinic_db
JWT_SECRET=my-super-secret-jwt-key-2024
REFRESH_TOKEN_SECRET=my-refresh-token-secret-2024
PORT=3000
NODE_ENV=development
```

**Windows users**: Use `notepad .env` to edit
**macOS/Linux**: Use `nano .env` or your preferred editor

### 5. Run Migrations (30 seconds)

```bash
npm run migrate
```

Expected output:
```
Starting database migrations...
✓ Database connection successful
✓ Migrations table ready
→ Executing 001_initial_schema.sql...
✓ Successfully executed 001_initial_schema.sql
✓ All migrations completed successfully!
```

### 6. Verify Setup (30 seconds)

```bash
node test-connection.js
```

Expected output:
```
✓ Database connection successful
✓ Found 10 tables
✓ Found 20+ indexes
✅ Setup complete!
```

### 7. Start Server (10 seconds)

```bash
# Development mode (auto-reload)
npm run dev

# Or production mode
npm start
```

Expected output:
```
Server listening on port 3000
✓ Database connection successful
```

Visit: http://localhost:3000

## Verification Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `clinic_db` created
- [ ] Dependencies installed (`node_modules/` folder exists)
- [ ] `.env` file configured with correct DATABASE_URL
- [ ] Migrations ran successfully
- [ ] Test connection script passed
- [ ] Server starts without errors

## Troubleshooting

### "Cannot connect to database"

**Cause**: PostgreSQL not running

**Fix Windows**:
```bash
# Check service
sc query postgresql-x64-15

# Start service
net start postgresql-x64-15
```

**Fix macOS**:
```bash
# Check status
brew services list

# Start service
brew services start postgresql@15
```

**Fix Linux**:
```bash
# Check status
sudo systemctl status postgresql

# Start service
sudo systemctl start postgresql
```

### "password authentication failed"

**Cause**: Wrong password in DATABASE_URL

**Fix**:
1. Open `.env` file
2. Update password in `DATABASE_URL`
3. Restart server

### "database clinic_db does not exist"

**Cause**: Database not created

**Fix**:
```bash
psql -U postgres
CREATE DATABASE clinic_db;
\q
```

### "ECONNREFUSED 127.0.0.1:5432"

**Cause**: PostgreSQL not listening on port 5432

**Fix**:
1. Check PostgreSQL is running (see above)
2. Verify port in `postgresql.conf`:
   - Windows: `C:\Program Files\PostgreSQL\15\data\postgresql.conf`
   - macOS: `/usr/local/var/postgresql@15/postgresql.conf`
   - Linux: `/etc/postgresql/15/main/postgresql.conf`
3. Look for: `port = 5432`

### "Module not found"

**Cause**: Dependencies not installed

**Fix**:
```bash
rm -rf node_modules
rm package-lock.json
npm install
```

### "Migration failed"

**Cause**: Schema already exists or SQL error

**Fix**:
```bash
# Check what's executed
node migrations/run-migrations.js status

# Drop and recreate database (CAUTION: deletes all data)
psql -U postgres
DROP DATABASE clinic_db;
CREATE DATABASE clinic_db;
\q

# Run migrations again
npm run migrate
```

## Testing Database

Run verification queries:

```bash
psql -U postgres -d clinic_db -f migrations/verify-schema.sql
```

This will show:
- All tables created (10 tables)
- All indexes created (20+ indexes)
- All foreign keys
- All triggers

## Next Steps

✅ Database setup complete!

Now you can:

1. 🚀 Start implementing API endpoints (see README.md)
2. 🔐 Set up authentication middleware
3. 🌐 Create REST API routes
4. 🔌 Implement WebSocket server
5. 🧪 Write tests

## Quick Commands Reference

```bash
# Start server
npm run dev              # Development with auto-reload
npm start                # Production mode

# Database
npm run migrate          # Run migrations
psql -U postgres -d clinic_db  # Connect to database

# View logs
tail -f logs/app.log     # Live log viewing

# Check migration status
node migrations/run-migrations.js status

# Install dependencies
npm install

# Update dependencies
npm update
```

## Database Backup

**Create backup:**
```bash
pg_dump -U postgres clinic_db > backup.sql
```

**Restore backup:**
```bash
psql -U postgres clinic_db < backup.sql
```

## Getting Help

- Check README.md for detailed documentation
- Review error messages carefully
- Check PostgreSQL logs:
  - Windows: `C:\Program Files\PostgreSQL\15\data\log\`
  - macOS: `/usr/local/var/log/postgres.log`
  - Linux: `/var/log/postgresql/`

---

**Total Setup Time**: ~5-10 minutes ⏱️

**Status**: ✅ Ready for development!
