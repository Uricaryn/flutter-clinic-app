import { query, getClient } from '../config/database.js';

export class Appointment {
  // Create a new appointment
  static async create(appointmentData) {
    const {
      clinicId,
      patientId,
      patientName,
      patientPhone,
      procedureId,
      procedureName,
      operatorId,
      operatorName,
      dateTime,
      status,
      notes,
      paymentAmount,
      paymentDate,
      paymentMethod,
      paymentNote,
      stockItems,
    } = appointmentData;

    const client = await getClient();

    try {
      await client.query('BEGIN');

      // Insert appointment
      const appointmentSql = `
        INSERT INTO appointments (
          clinic_id, patient_id, patient_name, patient_phone, 
          procedure_id, procedure_name, operator_id, operator_name,
          date_time, status, notes, payment_amount, payment_date, 
          payment_method, payment_note
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
        RETURNING id, clinic_id, patient_id, patient_name, patient_phone,
                  procedure_id, procedure_name, operator_id, operator_name,
                  date_time, status, notes, payment_amount, payment_date,
                  payment_method, payment_note, created_at, updated_at
      `;

      const appointmentValues = [
        clinicId,
        patientId,
        patientName,
        patientPhone,
        procedureId,
        procedureName,
        operatorId,
        operatorName,
        dateTime,
        status || 'scheduled',
        notes,
        paymentAmount,
        paymentDate,
        paymentMethod,
        paymentNote,
      ];

      const appointmentResult = await client.query(appointmentSql, appointmentValues);
      const appointment = appointmentResult.rows[0];

      // Insert stock items if provided
      if (stockItems && stockItems.length > 0) {
        for (const item of stockItems) {
          const stockSql = `
            INSERT INTO appointment_stock_items (
              appointment_id, stock_item_id, stock_item_name, quantity, unit, cost
            )
            VALUES ($1, $2, $3, $4, $5, $6)
          `;

          await client.query(stockSql, [
            appointment.id,
            item.stockItemId,
            item.stockItemName,
            item.quantity,
            item.unit,
            item.cost,
          ]);

          // Update stock quantity
          if (item.stockItemId) {
            const updateStockSql = `
              UPDATE stock_items
              SET quantity = quantity - $1, updated_at = CURRENT_TIMESTAMP
              WHERE id = $2 AND clinic_id = $3
            `;

            await client.query(updateStockSql, [item.quantity, item.stockItemId, clinicId]);
          }
        }
      }

      await client.query('COMMIT');
      return appointment;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Find appointment by ID
  static async findById(id, clinicId) {
    const sql = `
      SELECT a.*,
             json_agg(
               json_build_object(
                 'id', asi.id,
                 'stockItemId', asi.stock_item_id,
                 'stockItemName', asi.stock_item_name,
                 'quantity', asi.quantity,
                 'unit', asi.unit,
                 'cost', asi.cost
               )
             ) FILTER (WHERE asi.id IS NOT NULL) as stock_items
      FROM appointments a
      LEFT JOIN appointment_stock_items asi ON a.id = asi.appointment_id
      WHERE a.id = $1 AND a.clinic_id = $2
      GROUP BY a.id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get all appointments for a clinic
  static async findByClinicId(clinicId, options = {}) {
    let sql = `
      SELECT a.*
      FROM appointments a
      WHERE a.clinic_id = $1
    `;

    const values = [clinicId];
    let paramCount = 2;

    // Filter by date range
    if (options.startDate) {
      sql += ` AND a.date_time >= $${paramCount}`;
      values.push(options.startDate);
      paramCount++;
    }

    if (options.endDate) {
      sql += ` AND a.date_time <= $${paramCount}`;
      values.push(options.endDate);
      paramCount++;
    }

    // Filter by status
    if (options.status) {
      sql += ` AND a.status = $${paramCount}`;
      values.push(options.status);
      paramCount++;
    }

    // Filter by patient
    if (options.patientId) {
      sql += ` AND a.patient_id = $${paramCount}`;
      values.push(options.patientId);
      paramCount++;
    }

    sql += ` ORDER BY a.date_time DESC`;

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

  // Get upcoming appointments (today and future)
  static async findUpcoming(clinicId) {
    const sql = `
      SELECT a.*
      FROM appointments a
      WHERE a.clinic_id = $1 
        AND a.date_time >= CURRENT_DATE
        AND a.status = 'scheduled'
      ORDER BY a.date_time ASC
      LIMIT 50
    `;

    const result = await query(sql, [clinicId]);
    return result.rows;
  }

  // Update appointment
  static async update(id, clinicId, appointmentData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    const allowedFields = [
      'patient_id',
      'patient_name',
      'patient_phone',
      'procedure_id',
      'procedure_name',
      'operator_id',
      'operator_name',
      'date_time',
      'status',
      'notes',
      'payment_amount',
      'payment_date',
      'payment_method',
      'payment_note',
    ];

    Object.keys(appointmentData).forEach((key) => {
      const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(snakeKey) && appointmentData[key] !== undefined) {
        fields.push(`${snakeKey} = $${paramCount}`);
        values.push(appointmentData[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    values.push(id, clinicId);
    const sql = `
      UPDATE appointments
      SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND clinic_id = $${paramCount + 1}
      RETURNING *
    `;

    const result = await query(sql, values);
    return result.rows[0];
  }

  // Delete appointment
  static async delete(id, clinicId) {
    const sql = `
      DELETE FROM appointments
      WHERE id = $1 AND clinic_id = $2
      RETURNING id
    `;

    const result = await query(sql, [id, clinicId]);
    return result.rows[0];
  }

  // Get appointment statistics
  static async getStatistics(clinicId, startDate, endDate) {
    const sql = `
      SELECT 
        COUNT(*) as total_appointments,
        COUNT(*) FILTER (WHERE status = 'scheduled') as scheduled,
        COUNT(*) FILTER (WHERE status = 'completed') as completed,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled,
        COALESCE(SUM(payment_amount) FILTER (WHERE payment_amount IS NOT NULL), 0) as total_revenue
      FROM appointments
      WHERE clinic_id = $1
        AND date_time >= $2
        AND date_time <= $3
    `;

    const result = await query(sql, [clinicId, startDate, endDate]);
    return result.rows[0];
  }
}

export default Appointment;
