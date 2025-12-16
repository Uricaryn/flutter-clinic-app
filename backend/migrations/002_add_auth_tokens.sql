-- Migration: Add authentication token fields to users table
-- Date: 2024-12-16
-- Description: Adds fields for password reset and email verification tokens

-- Add reset token fields
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS reset_token VARCHAR(255),
ADD COLUMN IF NOT EXISTS reset_token_expiry TIMESTAMP;

-- Add verification token fields
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS verification_token VARCHAR(255),
ADD COLUMN IF NOT EXISTS verification_token_expiry TIMESTAMP;

-- Create indexes for faster token lookups
CREATE INDEX IF NOT EXISTS idx_users_reset_token ON users(reset_token) WHERE reset_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token) WHERE verification_token IS NOT NULL;

-- Add comments
COMMENT ON COLUMN users.reset_token IS 'SHA256 hash of password reset token';
COMMENT ON COLUMN users.reset_token_expiry IS 'Expiration timestamp for reset token (1 hour)';
COMMENT ON COLUMN users.verification_token IS 'SHA256 hash of email verification token';
COMMENT ON COLUMN users.verification_token_expiry IS 'Expiration timestamp for verification token (24 hours)';

-- Update updated_at trigger if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for users table if it doesn't exist
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

