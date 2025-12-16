import { query } from '../config/database.js';

export class StockItem {
  // Create a new stock item
  static async create(stockItemData) {
    const {
      clinicId,
      name,
      description,
      price,
      cost,
      quantity = 0,
      unit,
      minimumQuantity = 0,
    } = stockItemData;

    const sql = `
      INSERT INTO stock_items (clinic_id, name, description, price, cost, quantity, unit, minimum_quantity)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, clinic_id, name, description, price, cost, quantity, unit, minimum_quantity, last_restocked, created_at, updated_at
    `;

    const values = [clinicId, name, description, price, cost, quantity, unit, minimumQuantity];
    const result = await query(sql, values);
    return result.rows[0];
  }

  // Find stock item by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT id, clinic_id, name, description, price, cost, quantity, unit, minimum_quantity, last_restocked, created_at, updated_at
      FROM stock_items
      WHERE id = $1 AND clinic_id = $2
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get all stock items for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT *
      FROM stock_items
      WHERE clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Add search filter
    if (options.search) {
      sql += ` AND (name ILIKE $${paramCount} OR description ILIKE $${paramCount})`;
      values.push(`%${options.search}%`);
      paramCount++;
    }

    // Filter by low stock
    if (options.lowStock) {
      sql += ` AND quantity <= minimum_quantity`;
    }

    sql += ` ORDER BY name ASC`;

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

  // Update stock item
  static async update(id, clinicId, stockItemData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = [
      'name',
      'description',
      'price',
      'cost',
      'quantity',
      'unit',
      'minimum_quantity',
      'last_restocked',
    ];

    Object.keys(stockItemData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && stockItemData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(stockItemData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE stock_items
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING id, clinic_id, name, description, price, cost, quantity, unit, minimum_quantity, last_restocked, updated_at
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Update stock quantity
  static async updateQuantity(id, clinicId, quantityChange) {
    const sql = `
      UPDATE stock_items
      SET quantity = quantity + $1, 
          last_restocked = CASE WHEN $1 > 0 THEN CURRENT_TIMESTAMP ELSE last_restocked END,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $2 AND clinic_id = $3
      RETURNING id, clinic_id, name, quantity, unit, updated_at
    `;

    const result = await query(sql, [quantityChange, id, clinicId]);
    return result.rows[0];
  }

  // Delete stock item
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM stock_items
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get low stock items
  static async getLowStock(clinicId) {
    const sql = `
      SELECT id, clinic_id, name, description, quantity, unit, minimum_quantity, last_restocked
      FROM stock_items
      WHERE clinic_id = $1 AND quantity <= minimum_quantity
      ORDER BY quantity ASC
    `;

    const result = await query(sql, [clinicId]);
    return result.rows;
  }

  // Count stock items for a clinic
  static async countByClinicId(clinicId) {
    const sql = `
      SELECT COUNT(*) as count
      FROM stock_items
      WHERE clinic_id = $1
    `;

    const result = await query(sql, [clinicId]);
    return parseInt(result.rows[0].count);
  }
}

export default StockItem;

