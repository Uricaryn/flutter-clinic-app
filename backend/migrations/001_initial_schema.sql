-- Flutter Clinic App - PostgreSQL Database Schema
-- Migration: 001_initial_schema
-- Description: Initial database schema with all tables, relationships, and indexes

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- MAIN TABLES
-- ============================================================================

-- Clinics Table
CREATE TABLE IF NOT EXISTS clinics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  specialization VARCHAR(255),
  address TEXT,
  phone VARCHAR(50),
  email VARCHAR(255),
  phone_country_code VARCHAR(10),
  phone_number VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  owner_id UUID, -- Will be linked after users table is created
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  avatar TEXT,
  role VARCHAR(50) NOT NULL,
  clinic_id UUID REFERENCES clinics(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  last_logout TIMESTAMP
);

-- Add foreign key constraint for clinic owner after users table is created
ALTER TABLE clinics 
  ADD CONSTRAINT fk_clinics_owner 
  FOREIGN KEY (owner_id) 
  REFERENCES users(id) 
  ON DELETE SET NULL;

-- Patients Table
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(50),
  address TEXT,
  date_of_birth DATE,
  gender VARCHAR(20),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedures Table
CREATE TABLE IF NOT EXISTS procedures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  duration_minutes INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Items Table
CREATE TABLE IF NOT EXISTS stock_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  cost DECIMAL(10,2),
  quantity INTEGER DEFAULT 0,
  unit VARCHAR(50),
  minimum_quantity INTEGER DEFAULT 0,
  last_restocked TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Operators Table
CREATE TABLE IF NOT EXISTS operators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  role VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  is_email_verified BOOLEAN DEFAULT false,
  temporary_password BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
  patient_name VARCHAR(255),
  patient_phone VARCHAR(50),
  procedure_id UUID REFERENCES procedures(id) ON DELETE SET NULL,
  procedure_name VARCHAR(255),
  operator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  operator_name VARCHAR(255),
  date_time TIMESTAMP NOT NULL,
  status VARCHAR(50) DEFAULT 'scheduled',
  notes TEXT,
  payment_amount DECIMAL(10,2),
  payment_date TIMESTAMP,
  payment_method VARCHAR(50),
  payment_note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedure Materials (Junction Table)
CREATE TABLE IF NOT EXISTS procedure_materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  procedure_id UUID NOT NULL REFERENCES procedures(id) ON DELETE CASCADE,
  stock_item_id UUID NOT NULL REFERENCES stock_items(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  unit VARCHAR(50),
  UNIQUE(procedure_id, stock_item_id)
);

-- Appointment Stock Items (Used Materials)
CREATE TABLE IF NOT EXISTS appointment_stock_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  stock_item_id UUID REFERENCES stock_items(id) ON DELETE SET NULL,
  stock_item_name VARCHAR(255),
  quantity INTEGER,
  unit VARCHAR(50),
  cost DECIMAL(10,2)
);

-- Expenses Table
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  amount DECIMAL(10,2) NOT NULL,
  category VARCHAR(100),
  date DATE NOT NULL,
  invoice_number VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_clinic_id ON users(clinic_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Clinics Indexes
CREATE INDEX IF NOT EXISTS idx_clinics_owner_id ON clinics(owner_id);
CREATE INDEX IF NOT EXISTS idx_clinics_is_active ON clinics(is_active);

-- Patients Indexes
CREATE INDEX IF NOT EXISTS idx_patients_clinic_id ON patients(clinic_id);
CREATE INDEX IF NOT EXISTS idx_patients_full_name ON patients(full_name);
CREATE INDEX IF NOT EXISTS idx_patients_email ON patients(email);
CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone);

-- Appointments Indexes
CREATE INDEX IF NOT EXISTS idx_appointments_clinic_id ON appointments(clinic_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date_time ON appointments(date_time);
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_operator_id ON appointments(operator_id);
CREATE INDEX IF NOT EXISTS idx_appointments_procedure_id ON appointments(procedure_id);

-- Composite index for common queries
CREATE INDEX IF NOT EXISTS idx_appointments_clinic_date ON appointments(clinic_id, date_time);
CREATE INDEX IF NOT EXISTS idx_appointments_clinic_status ON appointments(clinic_id, status);

-- Stock Items Indexes
CREATE INDEX IF NOT EXISTS idx_stock_items_clinic_id ON stock_items(clinic_id);
CREATE INDEX IF NOT EXISTS idx_stock_items_name ON stock_items(name);

-- Procedures Indexes
CREATE INDEX IF NOT EXISTS idx_procedures_clinic_id ON procedures(clinic_id);
CREATE INDEX IF NOT EXISTS idx_procedures_is_active ON procedures(is_active);

-- Expenses Indexes
CREATE INDEX IF NOT EXISTS idx_expenses_clinic_id ON expenses(clinic_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);

-- Composite index for date range queries
CREATE INDEX IF NOT EXISTS idx_expenses_clinic_date ON expenses(clinic_id, date);

-- Operators Indexes
CREATE INDEX IF NOT EXISTS idx_operators_clinic_id ON operators(clinic_id);
CREATE INDEX IF NOT EXISTS idx_operators_email ON operators(email);
CREATE INDEX IF NOT EXISTS idx_operators_is_active ON operators(is_active);

-- Procedure Materials Indexes
CREATE INDEX IF NOT EXISTS idx_procedure_materials_procedure_id ON procedure_materials(procedure_id);
CREATE INDEX IF NOT EXISTS idx_procedure_materials_stock_item_id ON procedure_materials(stock_item_id);

-- Appointment Stock Items Indexes
CREATE INDEX IF NOT EXISTS idx_appointment_stock_items_appointment_id ON appointment_stock_items(appointment_id);
CREATE INDEX IF NOT EXISTS idx_appointment_stock_items_stock_item_id ON appointment_stock_items(stock_item_id);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clinics_updated_at BEFORE UPDATE ON clinics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_procedures_updated_at BEFORE UPDATE ON procedures
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stock_items_updated_at BEFORE UPDATE ON stock_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_operators_updated_at BEFORE UPDATE ON operators
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- NOTIFICATION TRIGGERS FOR REAL-TIME UPDATES
-- ============================================================================

-- Function to notify on table changes
CREATE OR REPLACE FUNCTION notify_table_change()
RETURNS TRIGGER AS $$
DECLARE
  notification JSON;
BEGIN
  notification = json_build_object(
    'table', TG_TABLE_NAME,
    'action', TG_OP,
    'id', COALESCE(NEW.id::text, OLD.id::text),
    'clinic_id', COALESCE(NEW.clinic_id::text, OLD.clinic_id::text)
  );
  
  PERFORM pg_notify('table_change', notification::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply notification triggers to main tables
CREATE TRIGGER notify_appointments_change
  AFTER INSERT OR UPDATE OR DELETE ON appointments
  FOR EACH ROW EXECUTE FUNCTION notify_table_change();

CREATE TRIGGER notify_patients_change
  AFTER INSERT OR UPDATE OR DELETE ON patients
  FOR EACH ROW EXECUTE FUNCTION notify_table_change();

CREATE TRIGGER notify_procedures_change
  AFTER INSERT OR UPDATE OR DELETE ON procedures
  FOR EACH ROW EXECUTE FUNCTION notify_table_change();

CREATE TRIGGER notify_stock_items_change
  AFTER INSERT OR UPDATE OR DELETE ON stock_items
  FOR EACH ROW EXECUTE FUNCTION notify_table_change();

CREATE TRIGGER notify_expenses_change
  AFTER INSERT OR UPDATE OR DELETE ON expenses
  FOR EACH ROW EXECUTE FUNCTION notify_table_change();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE clinics IS 'Stores clinic information';
COMMENT ON TABLE users IS 'Application users (clinic owners, staff)';
COMMENT ON TABLE patients IS 'Patient records';
COMMENT ON TABLE procedures IS 'Medical procedures/treatments offered';
COMMENT ON TABLE stock_items IS 'Inventory/stock management';
COMMENT ON TABLE appointments IS 'Appointment scheduling';
COMMENT ON TABLE procedure_materials IS 'Materials required for procedures';
COMMENT ON TABLE appointment_stock_items IS 'Materials used in appointments';
COMMENT ON TABLE expenses IS 'Clinic expenses tracking';
COMMENT ON TABLE operators IS 'Clinic operators/staff';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

