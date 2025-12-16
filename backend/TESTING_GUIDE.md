# Testing Guide

## Overview

This guide covers testing both the backend API and the Flutter app in dual-mode (Firebase and PostgreSQL).

## Backend Testing

### 1. Database Connection Test

```bash
cd backend

# Test PostgreSQL connection
node test-connection.js

# Expected output:
# ✅ PostgreSQL connection successful
# ✅ All 10 connection tests passed
```

### 2. Authentication System Test

```bash
# Test JWT authentication
node test-auth-system.js

# Expected output:
# ✅ User registration successful
# ✅ User login successful
# ✅ Token refresh successful
# ✅ Token validation successful
```

### 3. API Endpoints Test

```bash
# Start the backend server
npm start

# In another terminal, test endpoints
```

#### Test Authentication

```bash
# Register new user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "fullName": "Test User",
    "role": "admin"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'

# Save the accessToken from response
TOKEN="your-access-token-here"
```

#### Test Clinic Endpoints

```bash
# Create clinic
curl -X POST http://localhost:3000/api/clinics \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Clinic",
    "specialization": "General Medicine",
    "address": "123 Test St",
    "phone": "+905551234567",
    "email": "clinic@test.com"
  }'

# Get clinics
curl -X GET http://localhost:3000/api/clinics \
  -H "Authorization: Bearer $TOKEN"
```

#### Test Patient Endpoints

```bash
# Create patient
curl -X POST http://localhost:3000/api/patients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "+905551234567",
    "address": "123 Patient St",
    "dateOfBirth": "1990-01-01",
    "gender": "male",
    "notes": "Test patient",
    "clinicId": "your-clinic-id"
  }'
```

### 4. WebSocket Test

```bash
# Install wscat if not already installed
npm install -g wscat

# Connect to WebSocket (use your JWT token)
wscat -c "ws://localhost:3000/ws?token=$TOKEN"

# Once connected, subscribe to appointments
> {"type": "subscribe", "collection": "appointments"}

# Expected response:
< {"type":"subscribed","collection":"appointments","message":"Subscribed to appointments updates"}

# Test ping/pong
> {"type": "ping"}
< {"type": "pong"}
```

### 5. Email Service Test

```bash
# Make sure .env has Zoho SMTP settings
cat .env | grep SMTP

# Test password reset email
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'

# Check your email inbox (test@example.com)
# Should receive password reset email from info@whabbiton.com
```

## Flutter App Testing

### 1. Test Firebase Mode (Default)

```bash
cd ..  # Back to project root

# Run in Firebase mode
flutter run --dart-define=DB_MODE=firebase

# Test:
# - Login with existing Firebase user
# - View appointments
# - Create new appointment
# - Realtime updates work
# - All features function normally
```

### 2. Test PostgreSQL Mode

```bash
# Make sure backend is running
cd backend && npm start

# In another terminal
cd ..

# Run in PostgreSQL mode
flutter run --dart-define=DB_MODE=postgresql

# Test:
# - Login with PostgreSQL user (register first if needed)
# - View appointments
# - Create new appointment  
# - WebSocket realtime updates
# - All CRUD operations
```

### 3. Mode Switching Test

Test that the app correctly switches between modes:

```bash
# Test 1: Firebase mode
flutter run --dart-define=DB_MODE=firebase
# Verify: Uses Firestore, Firebase Auth

# Stop app

# Test 2: PostgreSQL mode
flutter run --dart-define=DB_MODE=postgresql
# Verify: Uses REST API, JWT auth

# Stop app

# Test 3: Default mode (should be Firebase)
flutter run
# Verify: Uses Firebase (as per app_mode.dart default)
```

### 4. Integration Tests

Create test files:

```dart
// test/integration/postgresql_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_app/core/services/api_service.dart';

void main() {
  group('PostgreSQL API Integration Tests', () {
    late ApiService api;

    setUp(() {
      api = ApiService();
    });

    test('Health check returns success', () async {
      final response = await api.get('/health');
      expect(response.statusCode, 200);
      expect(response.data['success'], true);
    });

    test('Login with valid credentials', () async {
      final response = await api.post('/auth/login', data: {
        'email': 'test@example.com',
        'password': 'Test123!',
      });
      
      expect(response.statusCode, 200);
      expect(response.data['accessToken'], isNotNull);
      expect(response.data['user'], isNotNull);
    });
  });
}
```

Run tests:

```bash
flutter test test/integration/
```

## Load Testing

### Backend Load Test

```bash
# Install Apache Bench
# On Windows: Use chocolatey
choco install apache-httpd

# Test concurrent requests
ab -n 1000 -c 10 http://localhost:3000/health

# Test with authentication
ab -n 100 -c 5 -H "Authorization: Bearer $TOKEN" \
   http://localhost:3000/api/appointments
```

### WebSocket Load Test

```javascript
// backend/test-websocket-load.js
import WebSocket from 'ws';

const TOKEN = 'your-test-token';
const connections = [];

// Create 100 concurrent WebSocket connections
for (let i = 0; i < 100; i++) {
  const ws = new WebSocket(`ws://localhost:3000/ws?token=${TOKEN}`);
  
  ws.on('open', () => {
    console.log(`Connection ${i} opened`);
    ws.send(JSON.stringify({
      type: 'subscribe',
      collection: 'appointments'
    }));
  });
  
  connections.push(ws);
}

console.log('Created 100 WebSocket connections');
```

Run:
```bash
node backend/test-websocket-load.js
```

## Test Checklist

### Backend API Tests

- [ ] Database connection successful
- [ ] Health endpoint returns 200
- [ ] User registration works
- [ ] User login returns JWT tokens
- [ ] Token refresh works
- [ ] Protected endpoints require authentication
- [ ] CRUD operations work for all entities:
  - [ ] Clinics
  - [ ] Patients
  - [ ] Appointments
  - [ ] Procedures
  - [ ] Stock Items
  - [ ] Expenses
  - [ ] Operators
- [ ] WebSocket connection works
- [ ] WebSocket subscription works
- [ ] Realtime updates are broadcast
- [ ] Multi-tenancy works (clinic isolation)
- [ ] Rate limiting is active
- [ ] Error handling works correctly
- [ ] Input validation works
- [ ] Email sending works (Zoho SMTP)

### Flutter App Tests (Firebase Mode)

- [ ] App starts successfully
- [ ] Login works
- [ ] Registration works
- [ ] View appointments
- [ ] Create appointment
- [ ] Edit appointment
- [ ] Delete appointment
- [ ] View patients
- [ ] Search patients
- [ ] Manage stock items
- [ ] Realtime updates work
- [ ] Logout works

### Flutter App Tests (PostgreSQL Mode)

- [ ] App starts successfully
- [ ] Login works (JWT)
- [ ] Registration works
- [ ] JWT token is stored securely
- [ ] Token refresh works automatically
- [ ] View appointments (from REST API)
- [ ] Create appointment
- [ ] Edit appointment
- [ ] Delete appointment
- [ ] WebSocket connection established
- [ ] Realtime updates work via WebSocket
- [ ] All CRUD operations work
- [ ] Logout works and clears tokens
- [ ] Reconnection works after network loss

### Cross-Mode Tests

- [ ] Can switch between modes
- [ ] Data format compatible
- [ ] Both modes can coexist
- [ ] No crashes when switching
- [ ] Proper cleanup when changing modes

## Performance Benchmarks

### API Response Times

Expected response times (local development):

```
GET  /health                    < 10ms
POST /api/auth/login            < 100ms
GET  /api/appointments          < 200ms
POST /api/appointments          < 300ms
GET  /api/patients              < 150ms
```

Test with:
```bash
time curl http://localhost:3000/health
```

### Database Query Performance

```sql
-- Test query performance
EXPLAIN ANALYZE
SELECT * FROM appointments
WHERE clinic_id = 'some-uuid'
AND date_time >= CURRENT_DATE
ORDER BY date_time;

-- Should use index scan (not sequential scan)
-- Execution time should be < 10ms for < 1000 records
```

### WebSocket Latency

Expected latency for realtime updates:
- Local: < 50ms
- Production: < 200ms

## Automated Testing

### Backend Unit Tests (Future)

```bash
# Install Jest
npm install --save-dev jest supertest

# Run tests
npm test
```

Example test:
```javascript
// backend/tests/appointments.test.js
import request from 'supertest';
import app from '../src/server.js';

describe('Appointments API', () => {
  let authToken;

  beforeAll(async () => {
    // Login and get token
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'Test123!'
      });
    authToken = response.body.accessToken;
  });

  test('GET /api/appointments returns appointments', async () => {
    const response = await request(app)
      .get('/api/appointments')
      .set('Authorization', `Bearer ${authToken}`);
    
    expect(response.status).toBe(200);
    expect(Array.isArray(response.body.appointments)).toBe(true);
  });

  test('POST /api/appointments creates appointment', async () => {
    const response = await request(app)
      .post('/api/appointments')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        patientName: 'Test Patient',
        // ... other fields
      });
    
    expect(response.status).toBe(201);
    expect(response.body.appointment.id).toBeDefined();
  });
});
```

### Flutter Widget Tests

```dart
// test/widgets/login_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
```

## Monitoring Tests

### Health Check Monitoring

```bash
# Setup monitoring (every 5 minutes)
*/5 * * * * curl -f http://localhost:3000/health || echo "Backend down!"
```

### Database Health Check

```sql
-- Check database health
SELECT 
  numbackends as connections,
  xact_commit as commits,
  xact_rollback as rollbacks,
  blks_read as blocks_read,
  blks_hit as blocks_hit
FROM pg_stat_database 
WHERE datname = 'clinic_db';
```

### WebSocket Connections Monitor

```bash
# Check WebSocket stats
curl http://localhost:3000/health | jq '.websocket'

# Expected output:
{
  "totalClients": 5,
  "clinics": {
    "clinic-uuid-1": 3,
    "clinic-uuid-2": 2
  }
}
```

## Test Data

### Create Test Data

```sql
-- Insert test clinic
INSERT INTO clinics (name, specialization, email) 
VALUES ('Test Clinic', 'General', 'test@clinic.com');

-- Insert test user
INSERT INTO users (email, password_hash, full_name, role, clinic_id)
VALUES ('test@example.com', '$2b$10$...', 'Test User', 'admin', 'clinic-id');

-- Insert test patient
INSERT INTO patients (clinic_id, full_name, email, phone)
VALUES ('clinic-id', 'Test Patient', 'patient@test.com', '+905551234567');
```

Or use the migration script to import real data from Firestore.

## Common Issues & Solutions

### Issue: Token expired

```bash
# Get new token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### Issue: WebSocket won't connect

1. Check backend is running: `npm start`
2. Verify token is valid
3. Check WebSocket service initialized in logs
4. Test with wscat first before using Flutter

### Issue: CORS errors

Update ALLOWED_ORIGINS in `.env`:
```env
ALLOWED_ORIGINS=http://localhost:*
```

### Issue: Database queries slow

```sql
-- Check if indexes are being used
EXPLAIN ANALYZE
SELECT * FROM appointments WHERE clinic_id = 'uuid';

-- Should show "Index Scan" not "Seq Scan"
```

## Test Report Template

After testing, document results:

```markdown
## Test Results - [Date]

### Backend API
- ✅ All endpoints responding
- ✅ Authentication working
- ✅ Database queries < 100ms
- ✅ WebSocket connections stable
- ✅ Email sending working (Zoho)

### Flutter App (Firebase Mode)
- ✅ Login/Logout
- ✅ All CRUD operations
- ✅ Realtime updates
- ⚠️ Issue: [describe any issues]

### Flutter App (PostgreSQL Mode)
- ✅ JWT authentication
- ✅ All REST API calls working
- ✅ WebSocket realtime working
- ✅ No memory leaks
- ⚠️ Issue: [describe any issues]

### Performance
- API average response: 150ms
- WebSocket latency: 45ms
- Database query average: 25ms

### Issues Found
1. [List any issues]
2. [Solutions applied]
```

## Continuous Testing

### Pre-commit Tests

```bash
# Before committing, run tests
npm test  # Backend tests
flutter test  # Flutter tests
```

### Pre-deployment Tests

```bash
# 1. Backend tests
cd backend
npm test
npm run test:auth

# 2. Flutter tests  
cd ..
flutter test

# 3. Build tests
flutter build apk --dart-define=DB_MODE=postgresql
# Should build without errors

# 4. Integration test
flutter drive --target=test_driver/app.dart
```

## Next Steps After Testing

Once all tests pass:

1. ✅ Mark all test items as complete
2. ✅ Document any issues found
3. ✅ Fix critical bugs
4. ✅ Prepare for deployment
5. ✅ Update documentation with test results
6. ✅ Create deployment checklist
7. ✅ Plan production rollout

## Test Environment Setup

For comprehensive testing, set up three environments:

### Development
```env
NODE_ENV=development
DATABASE_URL=postgresql://localhost:5432/clinic_db_dev
```

### Staging
```env
NODE_ENV=staging
DATABASE_URL=postgresql://staging-host:5432/clinic_db_staging
```

### Production
```env
NODE_ENV=production
DATABASE_URL=postgresql://prod-host:5432/clinic_db
```

Test the full deployment flow in staging before production!

