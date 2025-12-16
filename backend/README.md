# Clinic App Backend

Node.js + Express REST API backend with PostgreSQL database for the Flutter Clinic App.

## Features

- ✅ RESTful API with Express.js
- ✅ PostgreSQL database with connection pooling
- ✅ JWT authentication & authorization
- ✅ Role-based access control (admin, user, operator)
- ✅ Input validation with express-validator
- ✅ Security headers with Helmet
- ✅ CORS configuration
- ✅ Error handling middleware
- ✅ Database migrations
- ✅ Request logging

## Tech Stack

- **Runtime**: Node.js (ES Modules)
- **Framework**: Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT (jsonwebtoken)
- **Password Hashing**: bcrypt
- **Validation**: express-validator
- **Security**: helmet, cors

## Prerequisites

- Node.js 18+ (with ES Modules support)
- PostgreSQL 12+
- npm or yarn

## Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Set up environment variables**:
   Create a `.env` file in the backend directory:
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
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_EXPIRATION=7d
   REFRESH_TOKEN_SECRET=your-super-secret-refresh-token-key
   REFRESH_TOKEN_EXPIRATION=30d

   # CORS Configuration
   ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
   ```

3. **Create PostgreSQL database**:
   ```sql
   CREATE DATABASE clinic_db;
   ```

4. **Run database migrations**:
   ```bash
   npm run migrate
   ```

## Running the Server

### Development mode (with auto-restart):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/refresh-token` - Refresh access token

### Appointments

- `GET /api/appointments` - Get all appointments (with filters)
- `GET /api/appointments/upcoming` - Get upcoming appointments
- `GET /api/appointments/statistics` - Get appointment statistics
- `GET /api/appointments/:id` - Get single appointment
- `POST /api/appointments` - Create appointment
- `PUT /api/appointments/:id` - Update appointment
- `DELETE /api/appointments/:id` - Delete appointment

### Patients

- `GET /api/patients` - Get all patients (with search)
- `GET /api/patients/:id` - Get single patient
- `GET /api/patients/:id/appointments` - Get patient with appointment history
- `POST /api/patients` - Create patient
- `PUT /api/patients/:id` - Update patient
- `DELETE /api/patients/:id` - Delete patient

### Health Check

- `GET /health` - Server health check

## Authentication

All protected routes require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Example Login Request:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "your-password"
  }'
```

### Example Authenticated Request:

```bash
curl -X GET http://localhost:3000/api/appointments \
  -H "Authorization: Bearer <your-jwt-token>"
```

## Database Schema

### Main Tables:
- **clinics** - Clinic information
- **users** - User accounts with authentication
- **patients** - Patient records
- **procedures** - Available procedures/treatments
- **stock_items** - Inventory management
- **appointments** - Appointment scheduling
- **appointment_stock_items** - Materials used in appointments
- **procedure_materials** - Materials required for procedures
- **expenses** - Expense tracking
- **operators** - Clinic operators/staff

See `migrations/001_initial_schema.sql` for the complete schema.

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js       # PostgreSQL connection pool
│   │   └── auth.js           # JWT configuration
│   ├── models/
│   │   ├── User.js           # User model
│   │   ├── Clinic.js         # Clinic model
│   │   ├── Patient.js        # Patient model
│   │   └── Appointment.js    # Appointment model
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── appointmentController.js
│   │   └── patientController.js
│   ├── middleware/
│   │   ├── auth.js           # JWT authentication
│   │   ├── errorHandler.js   # Error handling
│   │   └── validator.js      # Input validation
│   ├── routes/
│   │   ├── auth.js
│   │   ├── appointments.js
│   │   └── patients.js
│   └── server.js             # Main application entry
├── migrations/
│   ├── 001_initial_schema.sql
│   └── run-migrations.js
├── package.json
└── .env
```

## Error Handling

All errors are handled by a centralized error handler that returns consistent JSON responses:

```json
{
  "success": false,
  "message": "Error message",
  "error": {
    "stack": "...",  // Only in development
    "details": {}    // Additional error details
  }
}
```

## Security Features

- ✅ Password hashing with bcrypt (10 rounds)
- ✅ JWT token authentication
- ✅ Helmet security headers
- ✅ CORS configuration
- ✅ SQL injection prevention (parameterized queries)
- ✅ Input validation and sanitization
- ✅ Role-based access control

## Testing

```bash
npm test
```

## Development Notes

- All database queries use parameterized statements to prevent SQL injection
- Passwords are hashed with bcrypt before storage
- JWT tokens expire after 7 days (configurable)
- All timestamps are stored in UTC
- Soft deletes are used for users and clinics (is_active flag)
- Foreign keys ensure referential integrity
- Indexes are created on frequently queried columns

## Deployment

For production deployment:

1. Set `NODE_ENV=production`
2. Use strong JWT secrets
3. Enable HTTPS
4. Set up database backups
5. Configure appropriate CORS origins
6. Use environment-specific database credentials
7. Set up logging and monitoring

## License

MIT

