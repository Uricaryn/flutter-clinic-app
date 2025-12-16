import { query } from '../config/database.js';

export class Procedure {
  // Create a new procedure
  static async create(procedureData) {
    const {
      clinicId,
      name,
      description,
      price,
      durationMinutes,
      isActive = true,
    } = procedureData;

    const sql = `
      INSERT INTO procedures (clinic_id, name, description, price, duration_minutes, is_active)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, clinic_id, name, description, price, duration_minutes, is_active, created_at, updated_at
    `;

    const values = [clinicId, name, description, price, durationMinutes, isActive];
    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find procedure by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT id, clinic_id, name, description, price, duration_minutes, is_active, created_at, updated_at
      FROM procedures
      WHERE id = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get all procedures for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT p.*,
             COUNT(a.id) as appointment_count
      FROM procedures p
      LEFT JOIN appointments a ON p.id = a.procedure_id
      WHERE p.clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Filter by active status
    if (options.isActive !== undefined) {
      sql += ` AND p.is_active = $${paramCount}`;
      values.push(options.isActive);
      paramCount++;
    }

    // Add search filter
    if (options.search) {
      sql += ` AND (p.name ILIKE $${paramCount} OR p.description ILIKE $${paramCount})`;
      values.push(`%${options.search}%`);
      paramCount++;
    }

    sql += ` GROUP BY p.id ORDER BY p.name ASC`;

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

  // Update procedure
  static async update(id, clinicId, procedureData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = ['name', 'description', 'price', 'duration_minutes', 'is_active'];

    Object.keys(procedureData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && procedureData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(procedureData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE procedures
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING id, clinic_id, name, description, price, duration_minutes, is_active, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Delete procedure
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM procedures
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get procedure with materials
  static async findWithMaterials(id, clinicId) {
    const procedureSql = `
      SELECT id, clinic_id, name, description, price, duration_minutes, is_active, created_at, updated_at
      FROM procedures
      WHERE id = $1 AND clinic_id = $2
    `;

    const materialsSql = `
      SELECT pm.id, pm.quantity, pm.unit,
             si.id as stock_item_id, si.name as stock_item_name, si.price, si.cost
      FROM procedure_materials pm
      JOIN stock_items si ON pm.stock_item_id = si.id
      WHERE pm.procedure_id = $1
    `;

    const procedureResult = await query(procedureSql, [id, clinicId]);
    const materialsResult = await query(materialsSql, [id]);

    if (procedureResult.rows.length === 0) {
      return null;
    }

    return {
      ...procedureResult.rows[0],
      materials: materialsResult.rows,
    };
  }

  // Count procedures for a clinic
  static async countByClinicId(clinicId) {
    const sql = `
      SELECT COUNT(*) as count
      FROM procedures
      WHERE clinic_id = $1
    `;

    const result = await query(sql, [clinicId]);
    return parseInt(result.rows[0].count);
  }
}

export default Procedure;
