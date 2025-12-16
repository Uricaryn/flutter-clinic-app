import { query } from '../config/database.js';

export class Clinic {
  // Create a new clinic
  static async create(clinicData) {
    const {
      name,
      specialization,
      address,
      phone,
      email,
      phoneCountryCode,
      phoneNumber,
      ownerId,
    } = clinicData;

    const sql = `
      INSERT INTO clinics (name, specialization, address, phone, email, 
                          phone_country_code, phone_number, owner_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, name, specialization, address, phone, email, 
                phone_country_code, phone_number, is_active, owner_id, 
                created_at, updated_at
    `;

    const values = [
      name,
      specialization,
      address,
      phone,
      email,
      phoneCountryCode,
      phoneNumber,
      ownerId,
    ];

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find clinic by ID
  static async findById(id) {
    const sql = `
      SELECT c.*, u.full_name as owner_name, u.email as owner_email
      FROM clinics c
      LEFT JOIN users u ON c.owner_id = u.id
      WHERE c.id = $1 AND c.is_active = true
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Get all clinics
  static async findAll() {
    const sql = `
      SELECT c.*, u.full_name as owner_name, u.email as owner_email
      FROM clinics c
      LEFT JOIN users u ON c.owner_id = u.id
      WHERE c.is_active = true
      ORDER BY c.created_at DESC
    `;

    const result = await query(sql);
    return result.rows;
  }

  // Update clinic
  static async update(id, clinicData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = [
      'name',
      'specialization',
      'address',
      'phone',
      'email',
      'phone_country_code',
      'phone_number',
    ];

    Object.keys(clinicData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && clinicData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(clinicData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id);
    const sql = `
      UPDATE clinics
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount}
      RETURNING id, name, specialization, address, phone, email, 
                phone_country_code, phone_number, is_active, owner_id, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Soft delete clinic
  static async delete(id) {
    const sql = `
      UPDATE clinics
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }

  // Get clinic statistics
  static async getStatistics(id) {
    const sql = `
      SELECT 
        (SELECT COUNT(*) FROM patients WHERE clinic_id = $1) as total_patients,
        (SELECT COUNT(*) FROM appointments WHERE clinic_id = $1) as total_appointments,
        (SELECT COUNT(*) FROM appointments WHERE clinic_id = $1 AND status = 'scheduled') as upcoming_appointments,
        (SELECT COUNT(*) FROM procedures WHERE clinic_id = $1 AND is_active = true) as active_procedures,
        (SELECT COUNT(*) FROM stock_items WHERE clinic_id = $1) as total_stock_items,
        (SELECT COUNT(*) FROM users WHERE clinic_id = $1 AND is_active = true) as total_users
    `;

    const result = await query(sql, [id]);
    return result.rows[0];
  }
}

export default Clinic;

