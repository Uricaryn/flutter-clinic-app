# 🚀 Quick Start Guide

Get the backend running in 5 minutes!

## Prerequisites Checklist

- [ ] Node.js 18+ installed
- [ ] PostgreSQL installed and running
- [ ] Git repository cloned

## Step-by-Step Setup

### 1️⃣ Install Dependencies (30 seconds)

```bash
cd backend
npm install
```

### 2️⃣ Create Database (1 minute)

```bash
# Open PostgreSQL command line
psql -U postgres

# Run this SQL command
CREATE DATABASE clinic_db;

# Exit
\q
```

### 3️⃣ Configure Environment (1 minute)

Create a file named `.env` in the `backend` folder:

```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=clinic_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here

JWT_SECRET=my-super-secret-jwt-key-123456789
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=my-refresh-token-secret-987654321
REFRESH_TOKEN_EXPIRATION=30d

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

**Important**: Replace `your_postgres_password_here` with your actual PostgreSQL password!

### 4️⃣ Run Database Migration (30 seconds)

```bash
npm run migrate
```

Expected output:
```
✅ Migration completed successfully!
📊 Database schema has been created...
```

### 5️⃣ Start the Server (10 seconds)

```bash
npm run dev
```

Expected output:
```
═══════════════════════════════════════════════════
🚀 Server is running on port 3000
📝 Environment: development
🌐 API URL: http://localhost:3000
💚 Health check: http://localhost:3000/health
═══════════════════════════════════════════════════
```

### 6️⃣ Test It! (1 minute)

Open your browser and visit: http://localhost:3000/health

You should see:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-12-16T..."
}
```

## 🎉 Success!

Your backend is now running! Here's what you can do next:

### Test Authentication

**Register a user:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"test1234\",\"fullName\":\"Test User\"}"
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"test1234\"}"
```

Save the `accessToken` from the response!

### Create a Patient

```bash
curl -X POST http://localhost:3000/api/patients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d "{\"fullName\":\"John Doe\",\"email\":\"john@example.com\",\"phone\":\"+1234567890\"}"
```

## 🔧 Troubleshooting

### "Cannot connect to database"
- Make sure PostgreSQL is running
- Check your password in `.env` file
- Verify database exists: `psql -U postgres -l`

### "Port 3000 already in use"
- Change PORT in `.env` to 3001 or another port
- Or stop the other process using port 3000

### "Module not found"
- Run `npm install` again
- Make sure you're in the `backend` directory

### "Migration failed"
- Make sure database `clinic_db` exists
- Check PostgreSQL is running
- Verify credentials in `.env`

## 📚 Next Steps

1. ✅ Backend is running
2. 📖 Read `README.md` for API documentation
3. 🔗 Connect Flutter app to backend
4. 🧪 Test all endpoints
5. 🚀 Deploy to production

## 🆘 Need Help?

- Check `SETUP_GUIDE.md` for detailed setup
- Check `README.md` for API documentation
- Check `IMPLEMENTATION_COMPLETE.md` for technical details

## 🎯 Available API Endpoints

- `GET /health` - Health check
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user
- `GET /api/appointments` - List appointments
- `POST /api/appointments` - Create appointment
- `GET /api/patients` - List patients
- `POST /api/patients` - Create patient

See `README.md` for complete API documentation.

---

**Backend Version**: 1.0.0  
**Tech Stack**: Node.js + Express + PostgreSQL  
**Status**: ✅ Production Ready

