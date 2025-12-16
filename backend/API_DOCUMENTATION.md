# Clinic App Backend API Documentation

## Overview

This document provides comprehensive documentation for all REST API endpoints in the Clinic App backend.

**Base URL:** `http://localhost:3000` (development) or `https://api.your-domain.com` (production)

**API Version:** 1.0.0

---

## Table of Contents

1. [Authentication](#authentication)
2. [Clinics](#clinics)
3. [Patients](#patients)
4. [Appointments](#appointments)
5. [Procedures](#procedures)
6. [Stock Items](#stock-items)
7. [Expenses](#expenses)
8. [Operators](#operators)

---

## Authentication

All endpoints except login, register, and public clinic endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Register

**POST** `/api/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "fullName": "John Doe",
  "phone": "+1234567890",
  "role": "owner"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "role": "owner"
    },
    "token": "jwt-token",
    "refreshToken": "refresh-token"
  }
}
```

### Login

**POST** `/api/auth/login`

Login with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "role": "owner",
      "clinicId": "clinic-uuid"
    },
    "token": "jwt-token",
    "refreshToken": "refresh-token"
  }
}
```

### Logout

**POST** `/api/auth/logout`

Logout the current user.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## Clinics

### Get All Clinics

**GET** `/api/clinics`

Get a list of all active clinics (public endpoint).

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Downtown Dental Clinic",
      "specialization": "Dentistry",
      "address": "123 Main St",
      "phone": "+1234567890",
      "email": "info@clinic.com",
      "isActive": true,
      "ownerId": "uuid",
      "ownerName": "John Doe",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Clinic by ID

**GET** `/api/clinics/:id`

Get details of a specific clinic (public endpoint).

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Downtown Dental Clinic",
    "specialization": "Dentistry",
    "address": "123 Main St",
    "phone": "+1234567890",
    "email": "info@clinic.com",
    "isActive": true,
    "ownerId": "uuid",
    "ownerName": "John Doe",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### Create Clinic

**POST** `/api/clinics`

Create a new clinic (requires authentication).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Downtown Dental Clinic",
  "specialization": "Dentistry",
  "address": "123 Main St",
  "phone": "+1234567890",
  "email": "info@clinic.com",
  "phoneCountryCode": "+1",
  "phoneNumber": "1234567890"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Clinic created successfully",
  "data": {
    "id": "uuid",
    "name": "Downtown Dental Clinic",
    "specialization": "Dentistry",
    "ownerId": "uuid",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### Update Clinic

**PUT** `/api/clinics/:id`

Update clinic details (requires authentication).

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)
```json
{
  "name": "Updated Clinic Name",
  "specialization": "General Dentistry",
  "address": "456 New St",
  "phone": "+9876543210"
}
```

**Response:** `200 OK`

### Get Clinic Statistics

**GET** `/api/clinics/:id/statistics`

Get statistics for a clinic (requires authentication).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalPatients": 150,
    "totalAppointments": 500,
    "upcomingAppointments": 25,
    "activeProcedures": 10,
    "totalStockItems": 75,
    "totalUsers": 5
  }
}
```

### Delete Clinic

**DELETE** `/api/clinics/:id`

Soft delete a clinic (requires authentication).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

## Patients

### Get All Patients

**GET** `/api/patients`

Get all patients for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `search` (optional): Search by name, email, or phone
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "clinicId": "uuid",
      "fullName": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+1234567890",
      "dateOfBirth": "1990-01-01",
      "gender": "female",
      "address": "123 Patient St",
      "notes": "Regular patient",
      "appointmentCount": "5",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Patient by ID

**GET** `/api/patients/:id`

Get details of a specific patient.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Patient

**POST** `/api/patients`

Create a new patient.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "fullName": "Jane Smith",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "dateOfBirth": "1990-01-01",
  "gender": "female",
  "address": "123 Patient St",
  "notes": "Regular patient"
}
```

**Response:** `201 Created`

### Update Patient

**PUT** `/api/patients/:id`

Update patient details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Delete Patient

**DELETE** `/api/patients/:id`

Delete a patient.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Patient with Appointments

**GET** `/api/patients/:id/appointments`

Get patient details including appointment history.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "fullName": "Jane Smith",
    "appointments": [
      {
        "id": "uuid",
        "dateTime": "2024-01-15T10:00:00.000Z",
        "status": "completed",
        "procedureName": "Cleaning",
        "operatorName": "Dr. Smith",
        "paymentAmount": "100.00"
      }
    ]
  }
}
```

---

## Appointments

### Get All Appointments

**GET** `/api/appointments`

Get all appointments for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `status` (optional): Filter by status (scheduled, completed, cancelled)
- `startDate` (optional): Filter by date range (ISO 8601)
- `endDate` (optional): Filter by date range (ISO 8601)
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`

### Get Appointment by ID

**GET** `/api/appointments/:id`

Get details of a specific appointment.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Appointment

**POST** `/api/appointments`

Create a new appointment.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "patientId": "uuid",
  "patientName": "Jane Smith",
  "patientPhone": "+1234567890",
  "procedureId": "uuid",
  "procedureName": "Cleaning",
  "operatorId": "uuid",
  "operatorName": "Dr. Smith",
  "dateTime": "2024-01-15T10:00:00.000Z",
  "status": "scheduled",
  "notes": "First appointment",
  "paymentAmount": "100.00",
  "paymentMethod": "cash"
}
```

**Response:** `201 Created`

### Update Appointment

**PUT** `/api/appointments/:id`

Update appointment details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Delete Appointment

**DELETE** `/api/appointments/:id`

Delete an appointment.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

## Procedures

### Get All Procedures

**GET** `/api/procedures`

Get all procedures for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `search` (optional): Search by name or description
- `isActive` (optional): Filter by active status (true/false)
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "clinicId": "uuid",
      "name": "Dental Cleaning",
      "description": "Standard teeth cleaning",
      "price": "100.00",
      "durationMinutes": 30,
      "isActive": true,
      "appointmentCount": "25",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Procedure by ID

**GET** `/api/procedures/:id`

Get details of a specific procedure.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Procedure

**POST** `/api/procedures`

Create a new procedure.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Dental Cleaning",
  "description": "Standard teeth cleaning",
  "price": 100.00,
  "durationMinutes": 30,
  "isActive": true
}
```

**Response:** `201 Created`

### Update Procedure

**PUT** `/api/procedures/:id`

Update procedure details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Delete Procedure

**DELETE** `/api/procedures/:id`

Delete a procedure.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Procedure with Materials

**GET** `/api/procedures/:id/materials`

Get procedure details including required materials.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Dental Cleaning",
    "price": "100.00",
    "materials": [
      {
        "id": "uuid",
        "stockItemId": "uuid",
        "stockItemName": "Gloves",
        "quantity": 2,
        "unit": "pair",
        "price": "5.00"
      }
    ]
  }
}
```

---

## Stock Items

### Get All Stock Items

**GET** `/api/stock`

Get all stock items for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `search` (optional): Search by name or description
- `lowStock` (optional): Filter items with low stock (true/false)
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "clinicId": "uuid",
      "name": "Gloves",
      "description": "Medical gloves",
      "price": "5.00",
      "cost": "3.00",
      "quantity": 100,
      "unit": "pair",
      "minimumQuantity": 20,
      "lastRestocked": "2024-01-01T00:00:00.000Z",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Low Stock Items

**GET** `/api/stock/low-stock`

Get all items with stock below minimum quantity.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Stock Item by ID

**GET** `/api/stock/:id`

Get details of a specific stock item.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Stock Item

**POST** `/api/stock`

Create a new stock item.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Gloves",
  "description": "Medical gloves",
  "price": 5.00,
  "cost": 3.00,
  "quantity": 100,
  "unit": "pair",
  "minimumQuantity": 20
}
```

**Response:** `201 Created`

### Update Stock Item

**PUT** `/api/stock/:id`

Update stock item details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Update Stock Quantity

**PATCH** `/api/stock/:id/quantity`

Update stock quantity (add or subtract).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "quantityChange": 50
}
```

Use negative numbers to subtract from stock.

**Response:** `200 OK`

### Delete Stock Item

**DELETE** `/api/stock/:id`

Delete a stock item.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

## Expenses

### Get All Expenses

**GET** `/api/expenses`

Get all expenses for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `search` (optional): Search by title, description, or invoice number
- `category` (optional): Filter by category
- `startDate` (optional): Filter by date range (YYYY-MM-DD)
- `endDate` (optional): Filter by date range (YYYY-MM-DD)
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "clinicId": "uuid",
      "title": "Office Supplies",
      "description": "Monthly office supplies",
      "amount": "250.00",
      "category": "supplies",
      "date": "2024-01-15",
      "invoiceNumber": "INV-001",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Expense by ID

**GET** `/api/expenses/:id`

Get details of a specific expense.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Expense

**POST** `/api/expenses`

Create a new expense.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Office Supplies",
  "description": "Monthly office supplies",
  "amount": 250.00,
  "category": "supplies",
  "date": "2024-01-15",
  "invoiceNumber": "INV-001"
}
```

**Response:** `201 Created`

### Update Expense

**PUT** `/api/expenses/:id`

Update expense details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Delete Expense

**DELETE** `/api/expenses/:id`

Delete an expense.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Expense Summary

**GET** `/api/expenses/summary`

Get expense summary grouped by category.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `startDate` (required): Start date (YYYY-MM-DD)
- `endDate` (required): End date (YYYY-MM-DD)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "category": "supplies",
      "count": "10",
      "totalAmount": "2500.00"
    },
    {
      "category": "utilities",
      "count": "5",
      "totalAmount": "1200.00"
    }
  ]
}
```

### Get Total Expenses

**GET** `/api/expenses/total`

Get total expenses for a period.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `startDate` (required): Start date (YYYY-MM-DD)
- `endDate` (required): End date (YYYY-MM-DD)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "count": "15",
    "totalAmount": "3700.00"
  }
}
```

---

## Operators

### Get All Operators

**GET** `/api/operators`

Get all operators for the authenticated user's clinic.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `search` (optional): Search by name or email
- `isActive` (optional): Filter by active status (true/false)
- `role` (optional): Filter by role
- `limit` (optional): Number of results per page
- `offset` (optional): Offset for pagination

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "clinicId": "uuid",
      "name": "Dr. John Smith",
      "email": "dr.smith@clinic.com",
      "phone": "+1234567890",
      "role": "dentist",
      "isActive": true,
      "isEmailVerified": true,
      "appointmentCount": "50",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

### Get Operator by ID

**GET** `/api/operators/:id`

Get details of a specific operator.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Create Operator

**POST** `/api/operators`

Create a new operator.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Dr. John Smith",
  "email": "dr.smith@clinic.com",
  "phone": "+1234567890",
  "role": "dentist",
  "isActive": true
}
```

**Response:** `201 Created`

### Update Operator

**PUT** `/api/operators/:id`

Update operator details.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (all fields optional)

**Response:** `200 OK`

### Delete Operator

**DELETE** `/api/operators/:id`

Delete an operator.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Operator with Appointments

**GET** `/api/operators/:id/appointments`

Get operator details including recent appointments (last 50).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Dr. John Smith",
    "email": "dr.smith@clinic.com",
    "role": "dentist",
    "appointments": [
      {
        "id": "uuid",
        "dateTime": "2024-01-15T10:00:00.000Z",
        "status": "completed",
        "patientName": "Jane Doe",
        "procedureName": "Cleaning",
        "paymentAmount": "100.00"
      }
    ]
  }
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email address"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "You do not have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "message": "Too many requests, please try again later"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error",
  "error": "Error details (only in development mode)"
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **General API routes:** 100 requests per 15 minutes per IP
- **Auth routes:** 5 login attempts per 15 minutes per IP

When rate limit is exceeded, the API returns a 429 status code with a `Retry-After` header.

---

## Pagination

Many list endpoints support pagination using `limit` and `offset` query parameters:

- `limit`: Number of items to return (default: no limit)
- `offset`: Number of items to skip (default: 0)

Example:
```
GET /api/patients?limit=20&offset=0  # First page
GET /api/patients?limit=20&offset=20 # Second page
```

---

## Date Formats

All dates should be in ISO 8601 format:

- **Date only:** `YYYY-MM-DD` (e.g., `2024-01-15`)
- **Date and time:** `YYYY-MM-DDTHH:mm:ss.sssZ` (e.g., `2024-01-15T10:30:00.000Z`)

---

## Testing the API

You can test the API using tools like:

- **Postman:** Import the endpoints and test interactively
- **curl:** Command-line HTTP client
- **Thunder Client:** VS Code extension

Example curl request:
```bash
curl -X GET http://localhost:3000/api/patients \
  -H "Authorization: Bearer your-jwt-token"
```

---

## Support

For issues or questions, please contact the development team or create an issue in the project repository.

