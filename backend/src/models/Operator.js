import { query } from '../config/database.js';

export class Operator {
  // Create a new operator
  static async create(operatorData) {
    const {
      clinicId,
      name,
      email,
      phone,
      role,
      isActive = true,
      isEmailVerified = false,
      temporaryPassword = false,
    } = operatorData;

    const sql = `
      INSERT INTO operators (clinic_id, name, email, phone, role, is_active, is_email_verified, temporary_password)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, clinic_id, name, email, phone, role, is_active, is_email_verified, temporary_password, created_at, updated_at
    `;

    const values = [clinicId, name, email, phone, role, isActive, isEmailVerified, temporaryPassword];
    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find operator by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT id, clinic_id, name, email, phone, role, is_active, is_email_verified, temporary_password, created_at, updated_at
      FROM operators
      WHERE id = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Find operator by email
  static async findByEmail(email, clinicId) {
    const sql = `
      SELECT id, clinic_id, name, email, phone, role, is_active, is_email_verified, temporary_password, created_at, updated_at
      FROM operators
      WHERE email = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [email, clinicId]);
    return result.rows[0];
  }

  // Get all operators for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT o.*,
             COUNT(a.id) as appointment_count
      FROM operators o
      LEFT JOIN appointments a ON o.id = a.operator_id
      WHERE o.clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Filter by active status
    if (options.isActive !== undefined) {
      sql += ` AND o.is_active = $${paramCount}`;
      values.push(options.isActive);
      paramCount++;
    }

    // Filter by role
    if (options.role) {
      sql += ` AND o.role = $${paramCount}`;
      values.push(options.role);
      paramCount++;
    }

    // Add search filter
    if (options.search) {
      sql += ` AND (o.name ILIKE $${paramCount} OR o.email ILIKE $${paramCount})`;
      values.push(`%${options.search}%`);
      paramCount++;
    }

    sql += ` GROUP BY o.id ORDER BY o.name ASC`;

    // Add pagination
    if (options.limit) {
      sql += ` LIMIT $${paramCount}`;
      values.push(options.limit);
      paramCount++;
    }

    if (options.offset) {
      sql += ` OFFSET $${paramCount}`;
      values.push(options.offset);
    }

    const result = await query(sql, values);
    return result.rows;
  }

  // Update operator
  static async update(id, clinicId, operatorData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = [
      'name',
      'email',
      'phone',
      'role',
      'is_active',
      'is_email_verified',
      'temporary_password',
    ];

    Object.keys(operatorData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && operatorData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(operatorData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE operators
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING id, clinic_id, name, email, phone, role, is_active, is_email_verified, temporary_password, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Delete operator
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM operators
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get operator with appointments
  static async findWithAppointments(id, clinicId) {
    const operatorSql = `
      SELECT id, clinic_id, name, email, phone, role, is_active, is_email_verified, created_at, updated_at
      FROM operators
      WHERE id = $1 AND clinic_id = $2
    `;

    const appointmentsSql = `
      SELECT id, date_time, status, patient_name, procedure_name, payment_amount, notes
      FROM appointments
      WHERE operator_id = $1 AND clinic_id = $2
      ORDER BY date_time DESC
      LIMIT 50
    `;

    const operatorResult = await query(operatorSql, [id, clinicId]);
    const appointmentsResult = await query(appointmentsSql, [id, clinicId]);

    if (operatorResult.rows.length === 0) {
      return null;
    }

    return {
      ...operatorResult.rows[0],
      appointments: appointmentsResult.rows,
    };
  }

  // Count operators for a clinic
  static async countByClinicId(clinicId) {
    const sql = `
      SELECT COUNT(*) as count
      FROM operators
      WHERE clinic_id = $1
    `;

    const result = await query(sql, [clinicId]);
    return parseInt(result.rows[0].count);
  }
}

export default Operator;

