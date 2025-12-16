import { query } from '../config/database.js';
import bcrypt from 'bcrypt';

export class User {
  // Create a new user
  static async create(userData) {
    const {
      email,
      password,
      fullName,
      phone,
      avatar,
      role,
      clinicId,
    } = userData;

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    const sql = `
      INSERT INTO users (email, password_hash, full_name, phone, avatar, role, clinic_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, email, full_name, phone, avatar, role, clinic_id, is_active, 
                email_verified, created_at, updated_at
    `;

    const values = [email, passwordHash, fullName, phone, avatar, role, clinicId];
    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find user by ID
  static async findById(id) {
    const sql = `
      SELECT id, email, full_name, phone, avatar, role, clinic_id, is_active,
             email_verified, created_at, updated_at, last_login, last_logout
      FROM users
      WHERE id = $1 AND is_active = true
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Find user by email
  static async findByEmail(email) {
    const sql = `
      SELECT id, email, password_hash, full_name, phone, avatar, role, clinic_id, 
             is_active, email_verified, created_at, updated_at
      FROM users
      WHERE email = $1
    `;

    const result = await query(sql, [email]);
    return result.rows[0];
  }

  // Verify password
  static async verifyPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  // Update user
  static async update(id, userData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(userData).forEach((key) => {
      if (userData[key] !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        values.push(userData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id);
    const sql = `
      UPDATE users
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount}
      RETURNING id, email, full_name, phone, avatar, role, clinic_id, is_active,
                email_verified, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Update last login
  static async updateLastLogin(id) {
    const sql = `
      UPDATE users
      SET last_login = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, last_login
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Update last logout
  static async updateLastLogout(id) {
    const sql = `
      UPDATE users
      SET last_logout = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, last_logout
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Get all users for a clinic
  static async findByClinicId(clinicId) {
    const sql = `
      SELECT id, email, full_name, phone, avatar, role, clinic_id, is_active,
             email_verified, created_at, updated_at
      FROM users
      WHERE clinic_id = $1 AND is_active = true
      ORDER BY created_at DESC
    `;

    const result = await query(sql, [clinicId]);
    return result.rows;
  }

  // Soft delete user
  static async delete(id) {
    const sql = `
      UPDATE users
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Update password
  static async updatePassword(id, newPassword) {
    const passwordHash = await bcrypt.hash(newPassword, 10);

    const sql = `
      UPDATE users
      SET password_hash = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING id
    `;

    const result = await query(sql, [passwordHash, id]);
    return result.rows[0];
  }

  // Find user by reset token
  static async findByResetToken(tokenHash) {
    const sql = `
      SELECT id, email, full_name, phone, avatar, role, clinic_id, is_active,
             email_verified, reset_token, reset_token_expiry
      FROM users
      WHERE reset_token = $1 
        AND reset_token_expiry > CURRENT_TIMESTAMP
        AND is_active = true
    `;

    const result = await query(sql, [tokenHash]);
    return result.rows[0];
  }

  // Find user by verification token
  static async findByVerificationToken(tokenHash) {
    const sql = `
      SELECT id, email, full_name, phone, avatar, role, clinic_id, is_active,
             email_verified, verification_token, verification_token_expiry
      FROM users
      WHERE verification_token = $1 
        AND verification_token_expiry > CURRENT_TIMESTAMP
        AND is_active = true
    `;

    const result = await query(sql, [tokenHash]);
    return result.rows[0];
  }
}

export default User;
