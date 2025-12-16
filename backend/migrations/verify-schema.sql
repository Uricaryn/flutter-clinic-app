-- Verification script for database schema
-- Run this to check if all tables and indexes were created successfully

-- Check PostgreSQL version
SELECT version();

-- Check if UUID extension is enabled
SELECT * FROM pg_extension WHERE extname = 'uuid-ossp';

-- List all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Count records in each table (should be 0 for fresh install)
SELECT 
  'clinics' as table_name, COUNT(*) as count FROM clinics
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'patients', COUNT(*) FROM patients
UNION ALL SELECT 'procedures', COUNT(*) FROM procedures
UNION ALL SELECT 'stock_items', COUNT(*) FROM stock_items
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'operators', COUNT(*) FROM operators
UNION ALL SELECT 'expenses', COUNT(*) FROM expenses
UNION ALL SELECT 'procedure_materials', COUNT(*) FROM procedure_materials
UNION ALL SELECT 'appointment_stock_items', COUNT(*) FROM appointment_stock_items;

-- List all indexes
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- List all foreign key constraints
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

-- List all triggers
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Check table sizes (should be very small for fresh install)
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_total_relation_size(schemaname||'.'||tablename) AS bytes
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Migration history
SELECT * FROM migrations ORDER BY executed_at;

-- ============================================================================
-- Quick Test Queries (Optional - Uncomment to test)
-- ============================================================================

-- Insert a test clinic
-- INSERT INTO clinics (name, specialization) 
-- VALUES ('Test Clinic', 'General Practice')
-- RETURNING *;

-- Insert a test user
-- INSERT INTO users (email, password_hash, full_name, role, clinic_id)
-- VALUES ('test@example.com', '$2b$10$test', 'Test User', 'owner', 
--   (SELECT id FROM clinics WHERE name = 'Test Clinic'))
-- RETURNING *;

-- Clean up test data
-- DELETE FROM users WHERE email = 'test@example.com';
-- DELETE FROM clinics WHERE name = 'Test Clinic';
