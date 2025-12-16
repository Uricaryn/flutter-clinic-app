# Flutter Clinic App Backend - Windows Setup Script
# Run this script to set up the backend on Windows

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Flutter Clinic App Backend Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Add PostgreSQL to PATH temporarily
$pgPath = "C:\Program Files\PostgreSQL\17\bin"
if (Test-Path $pgPath) {
    $env:Path += ";$pgPath"
    Write-Host "✓ Added PostgreSQL to PATH" -ForegroundColor Green
} else {
    Write-Host "✗ PostgreSQL not found at $pgPath" -ForegroundColor Red
    Write-Host "  Please update the path in this script" -ForegroundColor Yellow
}

# Step 2: Prompt for PostgreSQL password
Write-Host ""
Write-Host "Step 1: Database Configuration" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow
$postgresPassword = Read-Host "Enter your PostgreSQL password for user 'postgres'" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($postgresPassword)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Step 3: Create .env file
Write-Host ""
Write-Host "Step 2: Creating .env file..." -ForegroundColor Yellow
$envContent = @"
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=clinic_db
DB_USER=postgres
DB_PASSWORD=$plainPassword

# Connection String
DATABASE_URL=postgresql://postgres:$plainPassword@localhost:5432/clinic_db

# JWT Configuration
JWT_SECRET=clinic-app-super-secret-jwt-key-change-in-production-$(Get-Random)
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=clinic-app-refresh-token-secret-change-in-production-$(Get-Random)
REFRESH_TOKEN_EXPIRATION=30d

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "✓ .env file created" -ForegroundColor Green

# Step 4: Test PostgreSQL connection
Write-Host ""
Write-Host "Step 3: Testing PostgreSQL connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $plainPassword
try {
    $testResult = psql -U postgres -d postgres -c "SELECT version();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL connection successful" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL connection failed" -ForegroundColor Red
        Write-Host "  Error: $testResult" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ PostgreSQL connection failed: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Create database
Write-Host ""
Write-Host "Step 4: Creating database 'clinic_db'..." -ForegroundColor Yellow
$createDbResult = psql -U postgres -d postgres -c "CREATE DATABASE clinic_db;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Database 'clinic_db' created" -ForegroundColor Green
} else {
    if ($createDbResult -like "*already exists*") {
        Write-Host "⚠ Database 'clinic_db' already exists" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Failed to create database: $createDbResult" -ForegroundColor Red
    }
}

# Step 6: Install npm dependencies
Write-Host ""
Write-Host "Step 5: Installing npm dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ npm dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install npm dependencies" -ForegroundColor Red
    exit 1
}

# Step 7: Run migrations
Write-Host ""
Write-Host "Step 6: Running database migrations..." -ForegroundColor Yellow
npm run migrate
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Database migrations completed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to run migrations" -ForegroundColor Red
    exit 1
}

# Success!
Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Start the server: npm run dev" -ForegroundColor White
Write-Host "2. Test the API: http://localhost:3000/health" -ForegroundColor White
Write-Host ""
Write-Host "To start the development server now, run:" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
