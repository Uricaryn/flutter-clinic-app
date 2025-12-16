# Environment Variables Template

## Backend .env Configuration

Create a `.env` file in the `backend/` directory with these settings:

```env
# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

# PostgreSQL connection string
DATABASE_URL=postgresql://postgres:password@localhost:5432/clinic_db

# ============================================================================
# JWT AUTHENTICATION
# ============================================================================

# JWT Access Token Secret (minimum 32 characters)
JWT_SECRET=your-super-secret-jwt-key-min-32-characters-here

# JWT Access Token Expiration
JWT_EXPIRATION=7d

# JWT Refresh Token Secret (different from JWT_SECRET!)
REFRESH_TOKEN_SECRET=another-super-secret-refresh-key-min-32-characters

# JWT Refresh Token Expiration
REFRESH_TOKEN_EXPIRATION=30d

# ============================================================================
# SERVER CONFIGURATION
# ============================================================================

PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:*,https://your-flutter-app.com

# ============================================================================
# ZOHO MAIL SMTP (info@whabbiton.com)
# ============================================================================

SMTP_HOST=smtp.zoho.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=info@whabbiton.com
SMTP_PASSWORD=your-zoho-app-password-here
EMAIL_FROM="Whabbiton Clinic <info@whabbiton.com>"
FRONTEND_URL=https://your-app-domain.com
```

## Quick Setup

```bash
# 1. Create .env file
cd backend
touch .env  # Or create manually on Windows

# 2. Copy the template above into .env

# 3. Update these values:
#    - DATABASE_URL: Your PostgreSQL connection
#    - JWT_SECRET: Generate with: openssl rand -hex 32
#    - REFRESH_TOKEN_SECRET: Generate another one
#    - SMTP_PASSWORD: Your Zoho App Password
#    - FRONTEND_URL: Your app's URL

# 4. Save and start backend
npm start
```

## Generate Secure Secrets

### On Linux/Mac:
```bash
openssl rand -hex 32
```

### On Windows (PowerShell):
```powershell
-join ((1..32) | ForEach-Object { '{0:X2}' -f (Get-Random -Maximum 256) })
```

### Online (if needed):
- https://www.uuidgenerator.net/
- Generate version 4 UUID and use as secret

## Zoho App Password Setup

1. Go to: https://accounts.zoho.com/
2. Navigate to: My Account → Security → App Passwords
3. Click "Generate New Password"
4. Name it: "Clinic Backend API"
5. Copy the generated password
6. Use it as SMTP_PASSWORD in .env

**Note:** This is more secure than using your main Zoho password!

## Production vs Development

### Development .env
```env
NODE_ENV=development
DATABASE_URL=postgresql://localhost:5432/clinic_db_dev
FRONTEND_URL=http://localhost:8080
ALLOWED_ORIGINS=*
```

### Production .env
```env
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@prod-db-host:5432/clinic_db
FRONTEND_URL=https://your-production-domain.com
ALLOWED_ORIGINS=https://your-production-domain.com
```

## Security Notes

⚠️ **IMPORTANT:**

1. **Never commit .env to git** (already in .gitignore)
2. **Use different secrets** for development and production
3. **Rotate secrets** periodically (every 3-6 months)
4. **Use App Passwords** instead of main passwords
5. **Restrict CORS** in production (no * wildcard)
6. **Use HTTPS** in production (wss:// for WebSocket)

## Troubleshooting

### Backend won't start

Check for:
- Missing .env file
- Invalid DATABASE_URL format
- PostgreSQL not running
- Port 3000 already in use

### Emails not sending

Check:
- SMTP_USER and SMTP_PASSWORD are correct
- Zoho App Password if 2FA is enabled
- Port 587 is not blocked by firewall
- Email addresses are valid

### Database connection errors

Check:
- PostgreSQL is running
- DATABASE_URL has correct credentials
- Database exists
- Network connectivity

## Complete Example .env

```env
# Database
DATABASE_URL=postgresql://postgres:mypassword@localhost:5432/clinic_db

# JWT
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
REFRESH_TOKEN_SECRET=z6y5x4w3v2u1t0s9r8q7p6o5n4m3l2k1j0i9h8g7f6e5d4c3b2a1
JWT_EXPIRATION=7d
REFRESH_TOKEN_EXPIRATION=30d

# Server
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:*

# Zoho Mail
SMTP_HOST=smtp.zoho.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=info@whabbiton.com
SMTP_PASSWORD=your-zoho-app-password
EMAIL_FROM="Whabbiton Clinic <info@whabbiton.com>"
FRONTEND_URL=http://localhost:8080
```

Save this as `backend/.env` and update with your actual values!
