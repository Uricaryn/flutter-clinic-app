import Operator from '../models/Operator.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new operator
export const createOperator = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const operatorData = {
    ...req.body,
    clinicId,
  };

  // Check if operator with this email already exists
  const existingOperator = await Operator.findByEmail(operatorData.email, clinicId);
  if (existingOperator) {
    return res.status(400).json({
      success: false,
      message: 'Operator with this email already exists',
    });
  }

  const operator = await Operator.create(operatorData);

  res.status(201).json({
    success: true,
    message: 'Operator created successfully',
    data: operator,
  });
});

// Get all operators for a clinic
export const getOperators = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { search, isActive, role, limit, offset } = req.query;

  const options = {
    search,
    isActive: isActive !== undefined ? isActive === 'true' : undefined,
    role,
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const operators = await Operator.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: operators,
    count: operators.length,
  });
});

// Get a single operator
export const getOperator = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const operator = await Operator.findById(id, clinicId);

  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Operator not found',
    });
  }

  res.status(200).json({
    success: true,
    data: operator,
  });
});

// Get operator with appointments
export const getOperatorWithAppointments = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const operator = await Operator.findWithAppointments(id, clinicId);

  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Operator not found',
    });
  }

  res.status(200).json({
    success: true,
    data: operator,
  });
});

// Update an operator
export const updateOperator = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  // If email is being updated, check if it's already taken by another operator
  if (req.body.email) {
    const existingOperator = await Operator.findByEmail(req.body.email, clinicId);
    if (existingOperator && existingOperator.id !== id) {
      return res.status(400).json({
        success: false,
        message: 'Operator with this email already exists',
      });
    }
  }

  const operator = await Operator.update(id, clinicId, req.body);

  if (!operator) {
    return res.status(404).json({
      success: false,
      message: 'Operator not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Operator updated successfully',
    data: operator,
  });
});

// Delete an operator
export const deleteOperator = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await Operator.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Operator not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Operator deleted successfully',
  });
});

export default {
  createOperator,
  getOperators,
  getOperator,
  getOperatorWithAppointments,
  updateOperator,
  deleteOperator,
};

