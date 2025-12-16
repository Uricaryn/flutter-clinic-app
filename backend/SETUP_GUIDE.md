# Backend Setup Guide

Quick guide to get the backend up and running.

## Step 1: Install Dependencies

```bash
cd backend
npm install
```

## Step 2: Install PostgreSQL

If you don't have PostgreSQL installed:

### Windows:
- Download from: https://www.postgresql.org/download/windows/
- Or use Chocolatey: `choco install postgresql`

### macOS:
```bash
brew install postgresql
brew services start postgresql
```

### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

## Step 3: Create Database

```bash
# Access PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE clinic_db;

# Exit psql
\q
```

## Step 4: Configure Environment

Create `.env` file in the `backend` directory:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=clinic_db
DB_USER=postgres
DB_PASSWORD=your_password_here

# JWT Configuration
JWT_SECRET=change-this-to-a-random-secret-key-for-production
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=change-this-to-another-random-secret-key
REFRESH_TOKEN_EXPIRATION=30d

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

**Important**: Replace `your_password_here` with your PostgreSQL password!

## Step 5: Run Database Migration

This will create all the necessary tables:

```bash
npm run migrate
```

You should see:
```
✅ Migration completed successfully!
📊 Database schema has been created...
```

## Step 6: Start the Server

### Development mode (auto-restart on changes):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

## Step 7: Test the API

Open a browser or use curl:

```bash
# Health check
curl http://localhost:3000/health

# Should return:
# {"success": true, "message": "Server is running", "timestamp": "..."}
```

## Step 8: Test Authentication

Register a new user:

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test1234",
    "fullName": "Test User"
  }'
```

Login:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test1234"
  }'
```

## Troubleshooting

### Issue: "Failed to connect to database"

**Solution**: Check your PostgreSQL is running and credentials in `.env` are correct.

```bash
# Windows - Check if PostgreSQL is running
Get-Service postgresql*

# macOS/Linux
brew services list  # macOS
sudo systemctl status postgresql  # Linux
```

### Issue: "Cannot find module"

**Solution**: Make sure you ran `npm install`:

```bash
npm install
```

### Issue: "Port 3000 already in use"

**Solution**: Change the PORT in `.env` file or stop the other process:

```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:3000 | xargs kill
```

### Issue: Migration fails with "database does not exist"

**Solution**: Create the database first:

```bash
psql -U postgres -c "CREATE DATABASE clinic_db;"
```

## Next Steps

1. ✅ Backend is now running
2. 📱 Update Flutter app to connect to this backend
3. 🔄 Test API endpoints with Postman or curl
4. 🚀 Deploy to production when ready

## API Documentation

Once the server is running, you can access:

- **Root**: http://localhost:3000/
- **Health Check**: http://localhost:3000/health
- **API Base**: http://localhost:3000/api/

See `README.md` for complete API documentation.

## Production Deployment

For production deployment, see the deployment section in `README.md`.

Key points:
- Set `NODE_ENV=production`
- Use strong, random JWT secrets
- Enable HTTPS
- Set up database backups
- Configure monitoring and logging
