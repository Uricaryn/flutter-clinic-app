import { query } from '../config/database.js';

export class Expense {
  // Create a new expense
  static async create(expenseData) {
    const {
      clinicId,
      title,
      description,
      amount,
      category,
      date,
      invoiceNumber,
    } = expenseData;

    const sql = `
      INSERT INTO expenses (clinic_id, title, description, amount, category, date, invoice_number)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, clinic_id, title, description, amount, category, date, invoice_number, created_at, updated_at
    `;

    const values = [clinicId, title, description, amount, category, date, invoiceNumber];
    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find expense by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT id, clinic_id, title, description, amount, category, date, invoice_number, created_at, updated_at
      FROM expenses
      WHERE id = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get all expenses for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT *
      FROM expenses
      WHERE clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Filter by date range
    if (options.startDate) {
      sql += ` AND date >= $${paramCount}`;
      values.push(options.startDate);
      paramCount++;
    }

    if (options.endDate) {
      sql += ` AND date <= $${paramCount}`;
      values.push(options.endDate);
      paramCount++;
    }

    // Filter by category
    if (options.category) {
      sql += ` AND category = $${paramCount}`;
      values.push(options.category);
      paramCount++;
    }

    // Add search filter
    if (options.search) {
      sql += ` AND (title ILIKE $${paramCount} OR description ILIKE $${paramCount} OR invoice_number ILIKE $${paramCount})`;
      values.push(`%${options.search}%`);
      paramCount++;
    }

    sql += ` ORDER BY date DESC, created_at DESC`;

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

  // Update expense
  static async update(id, clinicId, expenseData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = ['title', 'description', 'amount', 'category', 'date', 'invoice_number'];

    Object.keys(expenseData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && expenseData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(expenseData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE expenses
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING id, clinic_id, title, description, amount, category, date, invoice_number, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Delete expense
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM expenses
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get expense summary by category
  static async getSummaryByCategory(clinicId, startDate, endDate) {
    const sql = `
      SELECT category, 
             COUNT(*) as count,
             SUM(amount) as total_amount
      FROM expenses
      WHERE clinic_id = $1
        AND date >= $2
        AND date <= $3
      GROUP BY category
      ORDER BY total_amount DESC
    `;

    const result = await query(sql, [clinicId, startDate, endDate]);
    return result.rows;
  }

  // Get total expenses for a period
  static async getTotalExpenses(clinicId, startDate, endDate) {
    const sql = `
      SELECT COUNT(*) as count,
             SUM(amount) as total_amount
      FROM expenses
      WHERE clinic_id = $1
        AND date >= $2
        AND date <= $3
    `;

    const result = await query(sql, [clinicId, startDate, endDate]);
    return result.rows[0];
  }

  // Count expenses for a clinic
  static async countByClinicId(clinicId) {
    const sql = `
      SELECT COUNT(*) as count
      FROM expenses
      WHERE clinic_id = $1
    `;

    const result = await query(sql, [clinicId]);
    return parseInt(result.rows[0].count);
  }
}

export default Expense;
