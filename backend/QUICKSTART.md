# 🚀 Quick Start - 5 Minutes

Get your PostgreSQL backend up and running in 5 minutes!

## Prerequisites

✅ Node.js installed (v16+)
✅ PostgreSQL installed (v13+)

## Step 1: Install Dependencies (30 seconds)

```bash
cd backend
npm install
```

## Step 2: Create Database (30 seconds)

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE clinic_db;

# Exit
\q
```

## Step 3: Configure Environment (1 minute)

```bash
# Copy template
cp .env.example .env
```

**Edit .env** and change YOUR_PASSWORD:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/clinic_db
JWT_SECRET=change-this-to-a-random-string
REFRESH_TOKEN_SECRET=change-this-too
```

**Windows**: `notepad .env`
**Mac/Linux**: `nano .env`

## Step 4: Run Migrations (30 seconds)

```bash
npm run migrate
```

You should see:
```
✓ Database connection successful
✓ Migrations table ready
✓ Successfully executed 001_initial_schema.sql
✓ All migrations completed successfully!
```

## Step 5: Test Connection (30 seconds)

```bash
node test-connection.js
```

Expected output:
```
✓ Database connection successful
✓ Found 11 tables
✓ Found 20+ indexes
✅ All tests passed!
```

## Step 6: Start Server (10 seconds)

```bash
npm run dev
```

Server runs at: http://localhost:3000

## ✅ Done!

Your PostgreSQL backend is ready!

## Next Steps

1. 📖 Read [README.md](README.md) for full documentation
2. 🗄️ Read [DATABASE.md](DATABASE.md) for schema details
3. 📋 Check [MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md) for next phases
4. 🔧 Read [SETUP.md](SETUP.md) for detailed setup guide

## Troubleshooting

**Can't connect to database?**
- Check PostgreSQL is running: `psql -U postgres`
- Verify password in .env file

**Migrations fail?**
- Ensure database exists: `psql -U postgres -l`
- Check DATABASE_URL format

**Need help?**
- See [SETUP.md](SETUP.md) for detailed troubleshooting

---

**Total time**: ~5 minutes ⏱️

**Status**: Ready for API development! 🎉
