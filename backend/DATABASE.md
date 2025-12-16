# Database Schema Documentation

Comprehensive documentation for the Clinic App PostgreSQL database schema.

## Overview

The database consists of 11 main tables designed to manage clinic operations including:
- 👥 User management and authentication
- 🏥 Multi-clinic support
- 👤 Patient records
- 📅 Appointment scheduling
- 💊 Procedure/treatment management
- 📦 Stock/inventory management
- 💰 Expense tracking
- 👨‍⚕️ Operator management

## Database ERD (Entity Relationship Diagram)

```
                    ┌─────────────┐
                    │   clinics   │◄────┐
                    └──────┬──────┘     │
                           │            │
              ┌────────────┴────────────┼──────────┬──────────┐
              │                         │          │          │
         ┌────▼─────┐            ┌─────▼────┐  ┌──▼─────┐ ┌──▼─────┐
         │  users   │            │ patients │  │expenses│ │operators│
         └────┬─────┘            └─────┬────┘  └────────┘ └─────────┘
              │                        │
              │            ┌───────────┴───────────┐
              │            │                       │
         ┌────▼──────┐  ┌──▼─────────────┐  ┌────▼──────┐
         │procedures │  │ appointments   │  │stock_items│
         └────┬──────┘  └──┬──────────┬──┘  └────┬──────┘
              │            │          │          │
              │            │          └──────────┼──────────┐
              │            │                     │          │
      ┌───────▼────────────▼──┐    ┌────────────▼──────────▼──────┐
      │ procedure_materials   │    │ appointment_stock_items       │
      └───────────────────────┘    └──────────────────────────────┘
```

## Tables

### 1. clinics

Stores clinic information. Each clinic is independent with its own data.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| name | VARCHAR(255) | Clinic name (required) |
| specialization | VARCHAR(255) | Medical specialization |
| address | TEXT | Physical address |
| phone | VARCHAR(50) | Main phone number |
| email | VARCHAR(255) | Contact email |
| phone_country_code | VARCHAR(10) | Country code for phone |
| phone_number | VARCHAR(50) | Phone number without code |
| is_active | BOOLEAN | Active status (default: true) |
| owner_id | UUID | FK to users (clinic owner) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Relationships:**
- Has many: users, patients, procedures, stock_items, expenses, operators
- Belongs to: users (owner)

**Indexes:**
- `idx_clinics_owner_id` on owner_id
- `idx_clinics_is_active` on is_active

---

### 2. users

Application users (clinic owners, staff members).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | VARCHAR(255) | Email (unique, required) |
| password_hash | VARCHAR(255) | Bcrypt hashed password |
| full_name | VARCHAR(255) | Full name (required) |
| phone | VARCHAR(50) | Phone number |
| avatar | TEXT | Avatar URL |
| role | VARCHAR(50) | User role (owner, admin, staff) |
| clinic_id | UUID | FK to clinics |
| is_active | BOOLEAN | Active status |
| email_verified | BOOLEAN | Email verification status |
| created_at | TIMESTAMP | Registration date |
| updated_at | TIMESTAMP | Last profile update |
| last_login | TIMESTAMP | Last login timestamp |
| last_logout | TIMESTAMP | Last logout timestamp |

**Relationships:**
- Belongs to: clinics
- Has many: appointments (as operator)

**Indexes:**
- `idx_users_email` on email (unique)
- `idx_users_clinic_id` on clinic_id
- `idx_users_role` on role
- `idx_users_is_active` on is_active

**Notes:**
- Passwords are hashed with bcrypt (default 10 rounds)
- JWT authentication uses this table
- Supports multiple users per clinic

---

### 3. patients

Patient records for each clinic.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| full_name | VARCHAR(255) | Patient name (required) |
| email | VARCHAR(255) | Email address |
| phone | VARCHAR(50) | Phone number |
| address | TEXT | Home address |
| date_of_birth | DATE | Birth date |
| gender | VARCHAR(20) | Gender |
| notes | TEXT | Medical notes |
| created_at | TIMESTAMP | Record creation date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics
- Has many: appointments

**Indexes:**
- `idx_patients_clinic_id` on clinic_id
- `idx_patients_full_name` on full_name
- `idx_patients_email` on email
- `idx_patients_phone` on phone

**Notes:**
- Patient data is isolated per clinic
- Cascade delete when clinic is deleted
- PHI (Protected Health Information) - handle carefully

---

### 4. procedures

Medical procedures/treatments offered by the clinic.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| name | VARCHAR(255) | Procedure name (required) |
| description | TEXT | Detailed description |
| price | DECIMAL(10,2) | Default price |
| duration_minutes | INTEGER | Expected duration |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics
- Has many: procedure_materials, appointments

**Indexes:**
- `idx_procedures_clinic_id` on clinic_id
- `idx_procedures_is_active` on is_active

**Notes:**
- Can have associated materials (procedure_materials table)
- Price can be overridden in appointments

---

### 5. stock_items

Inventory and stock management.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| name | VARCHAR(255) | Item name (required) |
| description | TEXT | Item description |
| price | DECIMAL(10,2) | Selling price |
| cost | DECIMAL(10,2) | Purchase cost |
| quantity | INTEGER | Current stock quantity |
| unit | VARCHAR(50) | Unit of measurement |
| minimum_quantity | INTEGER | Reorder threshold |
| last_restocked | TIMESTAMP | Last restock date |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics
- Has many: procedure_materials, appointment_stock_items

**Indexes:**
- `idx_stock_items_clinic_id` on clinic_id
- `idx_stock_items_name` on name

**Notes:**
- Track quantity changes via appointment_stock_items
- Low stock alerts when quantity < minimum_quantity
- Supports profit calculation (price - cost)

---

### 6. appointments

Appointment scheduling and management.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| patient_id | UUID | FK to patients (cascade delete) |
| patient_name | VARCHAR(255) | Patient name (denormalized) |
| patient_phone | VARCHAR(50) | Patient phone (denormalized) |
| procedure_id | UUID | FK to procedures |
| procedure_name | VARCHAR(255) | Procedure name (denormalized) |
| operator_id | UUID | FK to users (operator) |
| operator_name | VARCHAR(255) | Operator name (denormalized) |
| date_time | TIMESTAMP | Appointment date & time (required) |
| status | VARCHAR(50) | Status (scheduled, completed, cancelled) |
| notes | TEXT | Appointment notes |
| payment_amount | DECIMAL(10,2) | Payment received |
| payment_date | TIMESTAMP | Payment date |
| payment_method | VARCHAR(50) | Payment method |
| payment_note | TEXT | Payment notes |
| created_at | TIMESTAMP | Booking date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics, patients, procedures, users (operator)
- Has many: appointment_stock_items

**Indexes:**
- `idx_appointments_clinic_id` on clinic_id
- `idx_appointments_date_time` on date_time
- `idx_appointments_patient_id` on patient_id
- `idx_appointments_status` on status
- `idx_appointments_operator_id` on operator_id
- `idx_appointments_procedure_id` on procedure_id
- `idx_appointments_clinic_date` on (clinic_id, date_time) - composite
- `idx_appointments_clinic_status` on (clinic_id, status) - composite

**Notes:**
- Denormalized fields (patient_name, procedure_name) for historical accuracy
- Status values: scheduled, confirmed, in_progress, completed, cancelled, no_show
- Payment tracking integrated

---

### 7. operators

Clinic staff/operators (alternative to users for some workflows).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| name | VARCHAR(255) | Operator name (required) |
| email | VARCHAR(255) | Email (unique, required) |
| phone | VARCHAR(50) | Phone number |
| role | VARCHAR(50) | Operator role |
| is_active | BOOLEAN | Active status |
| is_email_verified | BOOLEAN | Email verification |
| temporary_password | BOOLEAN | Needs password reset |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics

**Indexes:**
- `idx_operators_clinic_id` on clinic_id
- `idx_operators_email` on email (unique)
- `idx_operators_is_active` on is_active

---

### 8. expenses

Clinic expense tracking.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| clinic_id | UUID | FK to clinics (required, cascade delete) |
| title | VARCHAR(255) | Expense title (required) |
| description | TEXT | Detailed description |
| amount | DECIMAL(10,2) | Expense amount (required) |
| category | VARCHAR(100) | Expense category |
| date | DATE | Expense date (required) |
| invoice_number | VARCHAR(100) | Invoice/receipt number |
| created_at | TIMESTAMP | Record creation date |
| updated_at | TIMESTAMP | Last update |

**Relationships:**
- Belongs to: clinics

**Indexes:**
- `idx_expenses_clinic_id` on clinic_id
- `idx_expenses_date` on date
- `idx_expenses_category` on category
- `idx_expenses_clinic_date` on (clinic_id, date) - composite

**Notes:**
- Categories: rent, utilities, supplies, salaries, marketing, etc.
- Used for financial reporting and profit/loss calculations

---

### 9. procedure_materials (Junction Table)

Materials required for each procedure.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| procedure_id | UUID | FK to procedures (cascade delete) |
| stock_item_id | UUID | FK to stock_items (cascade delete) |
| quantity | INTEGER | Required quantity |
| unit | VARCHAR(50) | Unit of measurement |

**Relationships:**
- Belongs to: procedures, stock_items

**Indexes:**
- `idx_procedure_materials_procedure_id` on procedure_id
- `idx_procedure_materials_stock_item_id` on stock_item_id
- UNIQUE constraint on (procedure_id, stock_item_id)

**Notes:**
- Defines default materials for procedures
- Actual usage tracked in appointment_stock_items

---

### 10. appointment_stock_items

Materials actually used in appointments.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| appointment_id | UUID | FK to appointments (cascade delete) |
| stock_item_id | UUID | FK to stock_items |
| stock_item_name | VARCHAR(255) | Item name (denormalized) |
| quantity | INTEGER | Quantity used |
| unit | VARCHAR(50) | Unit of measurement |
| cost | DECIMAL(10,2) | Cost at time of use |

**Relationships:**
- Belongs to: appointments, stock_items

**Indexes:**
- `idx_appointment_stock_items_appointment_id` on appointment_id
- `idx_appointment_stock_items_stock_item_id` on stock_item_id

**Notes:**
- Tracks actual material usage
- Denormalized fields for historical accuracy
- Updates stock_items.quantity (should be handled in application logic)

---

## Database Features

### 1. Automatic Timestamps

All tables with `created_at` and `updated_at` columns have automatic triggers:

```sql
CREATE TRIGGER update_[table]_updated_at 
BEFORE UPDATE ON [table]
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 2. Real-time Notifications

PostgreSQL LISTEN/NOTIFY triggers for real-time updates:

```sql
-- Triggers on: appointments, patients, procedures, stock_items, expenses
CREATE TRIGGER notify_[table]_change
AFTER INSERT OR UPDATE OR DELETE ON [table]
FOR EACH ROW EXECUTE FUNCTION notify_table_change();
```

**Usage in Node.js:**

```javascript
const client = await pool.connect();
await client.query('LISTEN table_change');

client.on('notification', (msg) => {
  const data = JSON.parse(msg.payload);
  // { table, action, id, clinic_id }
  // Broadcast to WebSocket clients
});
```

### 3. UUID Primary Keys

All tables use UUID v4 for primary keys:
- Globally unique
- No sequential leakage
- Better for distributed systems
- Enables offline-first capabilities

### 4. Cascade Deletes

Foreign keys configured with appropriate cascade behavior:
- `ON DELETE CASCADE`: Dependent records deleted (e.g., appointments when patient deleted)
- `ON DELETE SET NULL`: Reference nullified (e.g., appointment.procedure_id)

### 5. Indexes for Performance

Comprehensive indexing strategy:
- Primary keys (automatic)
- Foreign keys
- Search fields (name, email, phone)
- Filter fields (status, is_active)
- Date/time fields for range queries
- Composite indexes for common query patterns

## Common Queries

### Get all appointments for a clinic on a specific date

```sql
SELECT 
  a.*,
  p.full_name as patient_name,
  pr.name as procedure_name,
  u.full_name as operator_name
FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.id
LEFT JOIN procedures pr ON a.procedure_id = pr.id
LEFT JOIN users u ON a.operator_id = u.id
WHERE a.clinic_id = $1
  AND DATE(a.date_time) = $2
ORDER BY a.date_time;
```

### Get stock items below minimum quantity

```sql
SELECT *
FROM stock_items
WHERE clinic_id = $1
  AND quantity < minimum_quantity
ORDER BY quantity ASC;
```

### Calculate monthly revenue

```sql
SELECT 
  DATE_TRUNC('month', payment_date) as month,
  SUM(payment_amount) as revenue,
  COUNT(*) as paid_appointments
FROM appointments
WHERE clinic_id = $1
  AND payment_date IS NOT NULL
  AND payment_date >= $2
  AND payment_date < $3
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month DESC;
```

### Get patient appointment history

```sql
SELECT 
  a.date_time,
  a.procedure_name,
  a.operator_name,
  a.payment_amount,
  a.status
FROM appointments a
WHERE a.patient_id = $1
ORDER BY a.date_time DESC;
```

## Data Migration from Firestore

Firestore → PostgreSQL mapping:

| Firestore | PostgreSQL |
|-----------|------------|
| Document ID | UUID (generated) |
| Timestamp | TIMESTAMP |
| Reference | UUID foreign key |
| Map/Object | JSONB or separate table |
| Array | Separate junction table |
| Subcollection | Separate table with FK |

## Backup and Maintenance

### Daily Backup

```bash
pg_dump -U postgres clinic_db > backup_$(date +%Y%m%d).sql
```

### Restore Backup

```bash
psql -U postgres clinic_db < backup_20241216.sql
```

### Vacuum (Maintenance)

```bash
# Analyze and optimize
VACUUM ANALYZE;

# Full vacuum (requires downtime)
VACUUM FULL;
```

### Reindex

```bash
REINDEX DATABASE clinic_db;
```

## Performance Tuning

### Connection Pooling

Configured in `src/config/database.js`:
- max: 20 connections
- min: 5 connections
- idleTimeoutMillis: 30000ms

### Query Optimization

1. Use EXPLAIN ANALYZE to check query plans
2. Ensure proper indexes exist
3. Use prepared statements
4. Batch operations in transactions
5. Limit result sets with pagination

### Monitoring

```sql
-- Active queries
SELECT * FROM pg_stat_activity;

-- Table sizes
SELECT 
  pg_size_pretty(pg_total_relation_size('table_name'));

-- Index usage
SELECT * FROM pg_stat_user_indexes;

-- Cache hit ratio
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM pg_statio_user_tables;
```

## Security Considerations

1. **Password Storage**: Never store plain text passwords
2. **SQL Injection**: Use parameterized queries always
3. **Data Isolation**: Enforce clinic_id filters in all queries
4. **Audit Logging**: Consider adding audit tables for sensitive operations
5. **Encryption**: Use SSL/TLS for connections in production
6. **Backup Encryption**: Encrypt backup files
7. **Access Control**: Use PostgreSQL roles and permissions

## License

Part of the Clinic App project - Internal documentation
