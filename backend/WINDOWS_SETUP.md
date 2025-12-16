# PostgreSQL Setup for Windows

## Method 1: Install PostgreSQL (Recommended)

### Step 1: Download PostgreSQL

1. Go to: https://www.postgresql.org/download/windows/
2. Click "Download the installer"
3. Download the latest version (PostgreSQL 16 recommended)
4. Run the installer (.exe file)

### Step 2: Installation Process

During installation:
- **Password**: Set a password for the `postgres` user (remember this!)
- **Port**: Keep default 5432
- **Locale**: Keep default
- **Components**: Install all (PostgreSQL Server, pgAdmin 4, Command Line Tools)

### Step 3: Add PostgreSQL to PATH

After installation, add PostgreSQL to your system PATH:

1. Find your PostgreSQL bin directory (usually):
   ```
   C:\Program Files\PostgreSQL\16\bin
   ```

2. Add to PATH:
   - Press `Win + X` → Select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find "Path"
   - Click "Edit"
   - Click "New"
   - Add: `C:\Program Files\PostgreSQL\16\bin`
   - Click "OK" on all windows

3. **Restart PowerShell** (important!)

### Step 4: Test PostgreSQL

Open a new PowerShell window:

```powershell
psql --version
```

You should see: `psql (PostgreSQL) 16.x`

### Step 5: Create Database

```powershell
# Connect to PostgreSQL
psql -U postgres

# Enter your password when prompted

# Create database
CREATE DATABASE clinic_db;

# Verify
\l

# Exit
\q
```

---

## Method 2: Using pgAdmin (GUI - No Command Line Needed)

If you have pgAdmin installed (comes with PostgreSQL):

1. Open **pgAdmin 4** from Start Menu
2. Enter your master password (set during installation)
3. Expand "Servers" → "PostgreSQL 16" (enter postgres password)
4. Right-click "Databases" → "Create" → "Database..."
5. Enter database name: `clinic_db`
6. Click "Save"

Done! ✅

---

## Method 3: Using SQL Shell (psql)

If PostgreSQL is installed but psql isn't in PATH:

1. Open Start Menu
2. Search for "SQL Shell (psql)"
3. Press Enter to accept defaults (hit Enter 4 times)
4. Enter your postgres password
5. Run: `CREATE DATABASE clinic_db;`
6. Run: `\l` to verify
7. Run: `\q` to exit

---

## Method 4: Quick Install with Chocolatey

If you have Chocolatey package manager:

```powershell
# Install Chocolatey (if not installed)
# Visit: https://chocolatey.org/install

# Install PostgreSQL
choco install postgresql

# Restart PowerShell

# Create database
psql -U postgres -c "CREATE DATABASE clinic_db;"
```

---

## Verify Installation

After setup, verify PostgreSQL is working:

```powershell
# Check version
psql --version

# Test connection
psql -U postgres -d clinic_db -c "SELECT version();"
```

---

## Configure Backend

After creating the database, update your `.env` file:

```env
PORT=3000
NODE_ENV=development

# Use this format for Windows
DB_HOST=localhost
DB_PORT=5432
DB_NAME=clinic_db
DB_USER=postgres
DB_PASSWORD=your_password_here

# Or use connection string
DATABASE_URL=postgresql://postgres:your_password_here@localhost:5432/clinic_db

JWT_SECRET=my-super-secret-jwt-key-123456789
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=my-refresh-token-secret-987654321
REFRESH_TOKEN_EXPIRATION=30d

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

Replace `your_password_here` with the password you set during PostgreSQL installation.

---

## Troubleshooting

### "psql: command not found" after installation

**Solution**: Restart PowerShell or add to PATH manually (see Step 3 above)

### "psql: FATAL: password authentication failed"

**Solution**: Check your password in `.env` matches your PostgreSQL password

### "psql: could not connect to server"

**Solution**: 
1. Open Services (Win + R → `services.msc`)
2. Find "postgresql-x64-16" service
3. Right-click → Start

### Check if PostgreSQL is running

```powershell
Get-Service postgresql*
```

Should show "Running" status.

### Start PostgreSQL service

```powershell
Start-Service postgresql-x64-16
```

---

## Next Steps

Once PostgreSQL is installed and database is created:

```powershell
# 1. Go to backend folder
cd C:\Users\onura\flutter-clinic-app\backend

# 2. Install dependencies (if not done)
npm install

# 3. Run migrations
npm run migrate

# 4. Start server
npm run dev
```

---

## Alternative: Use Docker (Advanced)

If you prefer Docker:

```powershell
# Pull PostgreSQL image
docker pull postgres:16

# Run PostgreSQL container
docker run --name clinic-postgres `
  -e POSTGRES_PASSWORD=mysecretpassword `
  -e POSTGRES_DB=clinic_db `
  -p 5432:5432 `
  -d postgres:16

# Update .env
DATABASE_URL=postgresql://postgres:mysecretpassword@localhost:5432/clinic_db
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Check version | `psql --version` |
| Connect to PostgreSQL | `psql -U postgres` |
| Create database | `CREATE DATABASE clinic_db;` |
| List databases | `\l` |
| Connect to database | `\c clinic_db` |
| List tables | `\dt` |
| Exit | `\q` |

---

**Need Help?** Check the official PostgreSQL documentation: https://www.postgresql.org/docs/

