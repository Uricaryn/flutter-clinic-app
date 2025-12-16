import { query } from '../config/database.js';

export class Patient {
  // Create a new patient
  static async create(patientData) {
    const {
      clinicId,
      fullName,
      email,
      phone,
      address,
      dateOfBirth,
      gender,
      notes,
    } = patientData;

    const sql = `
      INSERT INTO patients (clinic_id, full_name, email, phone, address, 
                           date_of_birth, gender, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, clinic_id, full_name, email, phone, address, 
                date_of_birth, gender, notes, created_at, updated_at
    `;

    const values = [
      clinicId,
      fullName,
      email,
      phone,
      address,
      dateOfBirth,
      gender,
      notes,
    ];

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find patient by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT id, clinic_id, full_name, email, phone, address, 
             date_of_birth, gender, notes, created_at, updated_at
      FROM patients
      WHERE id = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get all patients for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT p.*, 
             COUNT(a.id) as appointment_count
      FROM patients p
      LEFT JOIN appointments a ON p.id = a.patient_id
      WHERE p.clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Add search filter
    if (options.search) {
      sql += ` AND (
        p.full_name ILIKE $${paramCount} OR 
        p.email ILIKE $${paramCount} OR 
        p.phone ILIKE $${paramCount}
      )`;
      values.push(`%${options.search}%`);
      paramCount++;
    }

    sql += ` GROUP BY p.id ORDER BY p.created_at DESC`;

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

  // Update patient
  static async update(id, clinicId, patientData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = [
      'full_name',
      'email',
      'phone',
      'address',
      'date_of_birth',
      'gender',
      'notes',
    ];

    Object.keys(patientData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && patientData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(patientData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE patients
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING id, clinic_id, full_name, email, phone, address, 
                date_of_birth, gender, notes, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Delete patient
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM patients
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get patient with appointment history
  static async findWithAppointments(id, clinicId) {
    const patientSql = `
      SELECT id, clinic_id, full_name, email, phone, address, 
             date_of_birth, gender, notes, created_at, updated_at
      FROM patients
      WHERE id = $1 AND clinic_id = $2
    `;

    const appointmentsSql = `
      SELECT id, date_time, status, procedure_name, operator_name, 
             payment_amount, payment_date, notes
      FROM appointments
      WHERE patient_id = $1 AND clinic_id = $2
      ORDER BY date_time DESC
    `;

    const patientResult = await query(patientSql, [id, clinicId]);
    const appointmentsResult = await query(appointmentsSql, [id, clinicId]);

    if (patientResult.rows.length === 0) {
      return null;
    }

    return {
      ...patientResult.rows[0],
      appointments: appointmentsResult.rows,
    };
  }

  // Count patients for a clinic
  static async countByClinicId(clinicId) {
    const sql = `
      SELECT COUNT(*) as count
      FROM patients
      WHERE clinic_id = $1
    `;

    const result = await query(sql, [clinicId]);
    return parseInt(result.rows[0].count);
  }
}

export default Patient;

