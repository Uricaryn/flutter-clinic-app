# Middleware Documentation

Complete guide to all authentication and authorization middleware in the backend.

## Table of Contents

- [Authentication Middleware](#authentication-middleware)
- [Authorization Middleware](#authorization-middleware)
- [Clinic Authorization Middleware](#clinic-authorization-middleware)
- [Rate Limiting Middleware](#rate-limiting-middleware)
- [Error Handling Middleware](#error-handling-middleware)
- [Validation Middleware](#validation-middleware)
- [Usage Examples](#usage-examples)

---

## Authentication Middleware

### `authenticate`

Verifies JWT token and attaches user info to request.

**Location:** `src/middleware/auth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';

router.get('/protected-route', authenticate, controller.method);
```

**What it does:**

1. Extracts token from `Authorization: Bearer <token>` header
2. Checks if token is blacklisted
3. Verifies token signature and expiration
4. Attaches user info to `req.user`:
   - `userId`: User's UUID
   - `email`: User's email
   - `role`: User's role
   - `clinicId`: User's clinic ID (if any)
5. Attaches token to `req.token` for potential blacklisting

**Request Object After Middleware:**

```javascript
req.user = {
  userId: 'uuid',
  email: 'user@example.com',
  role: 'user',
  clinicId: 'clinic-uuid'
};
req.token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**Error Responses:**

- `401`: No token provided
- `401`: Token blacklisted
- `401`: Invalid or expired token

**Example:**

```javascript
// Protected endpoint
router.get('/appointments', authenticate, async (req, res) => {
  const userId = req.user.userId;
  const clinicId = req.user.clinicId;
  // ... fetch appointments
});
```

---

## Authorization Middleware

### `requireRole(...roles)`

Ensures user has one of the specified roles.

**Location:** `src/middleware/auth.js`

**Usage:**

```javascript
import { authenticate, requireRole } from '../middleware/auth.js';

router.post('/admin-action', 
  authenticate, 
  requireRole('admin'), 
  controller.method
);

// Multiple roles
router.post('/staff-action', 
  authenticate, 
  requireRole('admin', 'operator'), 
  controller.method
);
```

**Parameters:**

- `...roles` (string[]): One or more role names to allow

**Allowed Roles:**

- `admin`: Super admin
- `owner`: Clinic owner
- `user`: Regular user
- `operator`: Clinic operator

**What it does:**

1. Checks if user is authenticated (`req.user` exists)
2. Verifies user's role matches one of the allowed roles
3. Allows access if role matches, denies otherwise

**Error Responses:**

- `401`: Authentication required
- `403`: Access denied - insufficient role

**Example:**

```javascript
// Only admins can delete users
router.delete('/users/:id', 
  authenticate, 
  requireRole('admin'), 
  userController.delete
);

// Owners and admins can manage clinic settings
router.put('/clinic/:id/settings', 
  authenticate, 
  requireRole('admin', 'owner'), 
  clinicController.updateSettings
);
```

---

### `requireClinic`

Ensures user belongs to a clinic.

**Location:** `src/middleware/auth.js`

**Usage:**

```javascript
import { authenticate, requireClinic } from '../middleware/auth.js';

router.get('/clinic-data', 
  authenticate, 
  requireClinic, 
  controller.method
);
```

**What it does:**

1. Checks if `req.user.clinicId` exists
2. Denies access if user doesn't belong to any clinic

**Error Responses:**

- `403`: User does not belong to any clinic

**Example:**

```javascript
// User must belong to a clinic to view appointments
router.get('/appointments', 
  authenticate, 
  requireClinic, 
  appointmentController.getAll
);
```

---

### `requireClinicAccess`

Validates user can access the specified clinic.

**Location:** `src/middleware/auth.js`

**Usage:**

```javascript
import { authenticate, requireClinicAccess } from '../middleware/auth.js';

router.get('/clinics/:clinicId/patients', 
  authenticate, 
  requireClinicAccess, 
  patientController.getAll
);
```

**What it does:**

1. Extracts `clinicId` from params, body, or query
2. Admin users can access all clinics
3. Regular users can only access their own clinic
4. Compares `clinicId` with `req.user.clinicId`

**Error Responses:**

- `400`: Clinic ID is required
- `403`: Access denied - wrong clinic

**Example:**

```javascript
// User can only view patients from their clinic
router.get('/clinics/:clinicId/patients', 
  authenticate, 
  requireClinicAccess, 
  async (req, res) => {
    const clinicId = req.params.clinicId;
    // User has been verified to have access to this clinic
    const patients = await Patient.findByClinicId(clinicId);
    res.json({ data: patients });
  }
);
```

---

## Clinic Authorization Middleware

### `validateClinicAccess`

Enhanced clinic access validation.

**Location:** `src/middleware/clinicAuth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';
import { validateClinicAccess } from '../middleware/clinicAuth.js';

router.get('/clinics/:clinicId/data', 
  authenticate, 
  validateClinicAccess, 
  controller.method
);
```

**What it does:**

1. Extracts `clinicId` from params, body, or query
2. Attaches `clinicId` to `req.clinicId`
3. Admin users bypass checks
4. Regular users must match their `clinicId`

**Request Object After Middleware:**

```javascript
req.clinicId = 'clinic-uuid'; // Extracted clinic ID
```

---

### `requireClinicMembership`

Ensures user belongs to a clinic and attaches clinic ID.

**Location:** `src/middleware/clinicAuth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';
import { requireClinicMembership } from '../middleware/clinicAuth.js';

router.get('/my-clinic-data', 
  authenticate, 
  requireClinicMembership, 
  controller.method
);
```

**What it does:**

1. Checks if `req.user.clinicId` exists
2. Attaches `req.clinicId = req.user.clinicId` for convenience

**Request Object After Middleware:**

```javascript
req.clinicId = 'clinic-uuid'; // User's clinic ID
```

---

### `requireClinicOwnership`

Ensures user owns or manages the clinic.

**Location:** `src/middleware/clinicAuth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';
import { requireClinicOwnership } from '../middleware/clinicAuth.js';

router.put('/clinics/:clinicId/settings', 
  authenticate, 
  requireClinicOwnership, 
  controller.updateSettings
);
```

**What it does:**

1. Extracts `clinicId` from params, body, or query
2. Admin users bypass checks
3. Regular users must:
   - Belong to the clinic (`clinicId` matches)
   - Have `owner` or `admin` role

**Error Responses:**

- `400`: Clinic ID is required
- `403`: Access denied - not the owner
- `403`: Access denied - insufficient role

---

### `requireClinicRole(...allowedRoles)`

Ensures user has specific role within their clinic.

**Location:** `src/middleware/clinicAuth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';
import { requireClinicRole } from '../middleware/clinicAuth.js';

router.delete('/patients/:id', 
  authenticate, 
  requireClinicRole('owner', 'admin'), 
  controller.delete
);
```

**Parameters:**

- `...allowedRoles` (string[]): Allowed roles

**What it does:**

1. Admin users bypass all checks
2. User must belong to a clinic
3. User must have one of the allowed roles

---

### `validateResourceClinic(resourceClinicId)`

Validates that a resource belongs to user's clinic.

**Location:** `src/middleware/clinicAuth.js`

**Usage:**

```javascript
import { authenticate } from '../middleware/auth.js';
import { validateResourceClinic } from '../middleware/clinicAuth.js';

router.get('/patients/:id', authenticate, async (req, res, next) => {
  const patient = await Patient.findById(req.params.id);
  
  if (!patient) {
    return res.status(404).json({ message: 'Patient not found' });
  }
  
  // Validate patient belongs to user's clinic
  validateResourceClinic(patient.clinic_id)(req, res, next);
  
  // If validation passes, continue
  res.json({ data: patient });
});
```

**Returns:** Middleware function

**What it does:**

1. Admin users bypass checks
2. Compares `resourceClinicId` with `req.user.clinicId`
3. Denies access if they don't match

---

## Rate Limiting Middleware

### `apiLimiter`

General rate limiter for all API routes.

**Location:** `src/middleware/rateLimiter.js`

**Usage:**

```javascript
import { apiLimiter } from '../middleware/rateLimiter.js';

// In server.js
app.use('/api/', apiLimiter);
```

**Configuration:**

- **Window:** 15 minutes (configurable via `RATE_LIMIT_WINDOW_MS`)
- **Max Requests:** 100 per window (configurable via `RATE_LIMIT_MAX_REQUESTS`)

**Response Headers:**

```
RateLimit-Limit: 100
RateLimit-Remaining: 95
RateLimit-Reset: 1234567890
```

**Error Response (429):**

```json
{
  "success": false,
  "message": "Too many requests from this IP, please try again later."
}
```

---

### `authLimiter`

Strict rate limiter for authentication endpoints.

**Location:** `src/middleware/rateLimiter.js`

**Usage:**

```javascript
import { authLimiter } from '../middleware/rateLimiter.js';

router.post('/login', authLimiter, loginValidation, validate, authController.login);
```

**Configuration:**

- **Window:** 15 minutes
- **Max Requests:** 5 per window
- **Skip Successful:** Yes (only failed attempts count)

**Use Cases:**

- Login endpoints
- Prevents brute force attacks

---

### `registerLimiter`

Rate limiter for user registration.

**Location:** `src/middleware/rateLimiter.js`

**Usage:**

```javascript
import { registerLimiter } from '../middleware/rateLimiter.js';

router.post('/register', registerLimiter, registerValidation, validate, authController.register);
```

**Configuration:**

- **Window:** 1 hour
- **Max Requests:** 5 per window

**Use Cases:**

- User registration
- Prevents spam accounts

---

### `passwordResetLimiter`

Rate limiter for password reset requests.

**Location:** `src/middleware/rateLimiter.js`

**Usage:**

```javascript
import { passwordResetLimiter } from '../middleware/rateLimiter.js';

router.post('/request-password-reset', 
  passwordResetLimiter, 
  validation, 
  validate, 
  authController.requestPasswordReset
);
```

**Configuration:**

- **Window:** 1 hour
- **Max Requests:** 3 per window

**Use Cases:**

- Password reset requests
- Prevents email spam

---

## Error Handling Middleware

### `asyncHandler`

Wraps async route handlers to catch errors.

**Location:** `src/middleware/errorHandler.js`

**Usage:**

```javascript
import { asyncHandler } from '../middleware/errorHandler.js';

export const getUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json({ data: user });
});
```

**What it does:**

1. Wraps async function
2. Catches any errors
3. Passes errors to error handler middleware

**Without asyncHandler:**

```javascript
export const getUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    res.json({ data: user });
  } catch (error) {
    next(error);
  }
};
```

---

### `errorHandler`

Global error handler middleware.

**Location:** `src/middleware/errorHandler.js`

**Usage:**

```javascript
import { errorHandler } from '../middleware/errorHandler.js';

// In server.js (must be last middleware)
app.use(errorHandler);
```

**What it does:**

1. Catches all errors from routes
2. Logs error details
3. Returns formatted error response

**Response Format:**

```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error (development only)"
}
```

---

### `notFoundHandler`

Handles 404 errors for undefined routes.

**Location:** `src/middleware/errorHandler.js`

**Usage:**

```javascript
import { notFoundHandler } from '../middleware/errorHandler.js';

// In server.js (before error handler)
app.use(notFoundHandler);
app.use(errorHandler);
```

**Response (404):**

```json
{
  "success": false,
  "message": "Route not found: /api/invalid-route"
}
```

---

## Validation Middleware

### `validate`

Validates request data using express-validator rules.

**Location:** `src/middleware/validator.js`

**Usage:**

```javascript
import { body } from 'express-validator';
import validate from '../middleware/validator.js';

const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

router.post('/login', loginValidation, validate, authController.login);
```

**What it does:**

1. Runs validation rules
2. Collects validation errors
3. Returns 400 if validation fails
4. Proceeds if validation passes

**Error Response (400):**

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email address"
    },
    {
      "field": "password",
      "message": "Password is required"
    }
  ]
}
```

---

## Usage Examples

### Example 1: Simple Protected Route

User must be authenticated:

```javascript
router.get('/profile', 
  authenticate, 
  userController.getProfile
);
```

### Example 2: Admin-Only Route

User must be authenticated and have admin role:

```javascript
router.delete('/users/:id', 
  authenticate, 
  requireRole('admin'), 
  userController.delete
);
```

### Example 3: Clinic-Specific Data

User must be authenticated and access their own clinic:

```javascript
router.get('/clinics/:clinicId/patients', 
  authenticate, 
  requireClinicAccess, 
  patientController.getAll
);
```

### Example 4: Clinic Owner Actions

User must be authenticated, be the owner, and access their clinic:

```javascript
router.put('/clinics/:clinicId/settings', 
  authenticate, 
  requireClinicOwnership, 
  clinicController.updateSettings
);
```

### Example 5: Rate-Limited Registration

Registration with validation and rate limiting:

```javascript
const registerValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('fullName').trim().notEmpty()
];

router.post('/register', 
  registerLimiter,           // Rate limit
  registerValidation,        // Validation rules
  validate,                  // Check validation
  authController.register    // Controller
);
```

### Example 6: Complex Authorization

Multiple middleware for strict access control:

```javascript
router.post('/clinics/:clinicId/patients/:patientId/procedures', 
  authenticate,                    // Must be logged in
  requireClinic,                   // Must belong to a clinic
  validateClinicAccess,            // Must access own clinic
  requireClinicRole('operator'),   // Must be operator or higher
  procedureController.create       // Controller
);
```

### Example 7: Resource Validation

Validate resource belongs to user's clinic:

```javascript
router.put('/patients/:id', 
  authenticate, 
  async (req, res, next) => {
    // Fetch patient
    const patient = await Patient.findById(req.params.id);
    
    if (!patient) {
      return res.status(404).json({ message: 'Patient not found' });
    }
    
    // Validate patient belongs to user's clinic
    const clinicCheck = validateResourceClinic(patient.clinic_id);
    clinicCheck(req, res, () => {
      // Validation passed, update patient
      patientController.update(req, res, next);
    });
  }
);
```

---

## Middleware Chain Order

Always use middleware in this order:

1. **Rate Limiting** (if applicable)
2. **Validation** (if applicable)
3. **Authentication** (`authenticate`)
4. **Authorization** (role/clinic checks)
5. **Controller/Handler**

**Example:**

```javascript
router.post('/resource',
  rateLimiter,        // 1. Rate limit
  validation,         // 2. Validate input
  validate,           // 2. Check validation
  authenticate,       // 3. Authenticate
  requireRole('...'), // 4. Authorize
  controller.create   // 5. Handle request
);
```

---

## Testing Middleware

### Test Authentication

```bash
# Without token (should fail)
curl http://localhost:3000/api/auth/me

# With token (should succeed)
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <your-token>"
```

### Test Rate Limiting

```bash
# Send multiple requests quickly
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"wrong"}'
done
```

### Test Authorization

```bash
# As regular user (should fail)
curl -X DELETE http://localhost:3000/api/users/123 \
  -H "Authorization: Bearer <user-token>"

# As admin (should succeed)
curl -X DELETE http://localhost:3000/api/users/123 \
  -H "Authorization: Bearer <admin-token>"
```

---

## Configuration

Environment variables affecting middleware:

```env
# JWT
JWT_SECRET=your-secret
JWT_EXPIRATION=7d

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000      # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100

# Security
NODE_ENV=production               # Affects error details in responses
```

---

## Best Practices

1. **Always authenticate first** before authorization
2. **Use rate limiters** on all public endpoints
3. **Validate inputs** before processing
4. **Use `asyncHandler`** for all async routes
5. **Check clinic access** for multi-tenant data
6. **Log authentication failures** for security monitoring
7. **Keep middleware focused** - one responsibility per middleware
8. **Test edge cases** - expired tokens, wrong clinics, etc.

---

**Version:** 1.0.0  
**Last Updated:** December 16, 2024
