import Procedure from '../models/Procedure.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new procedure
export const createProcedure = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const procedureData = {
    ...req.body,
    clinicId,
  };

  const procedure = await Procedure.create(procedureData);

  res.status(201).json({
    success: true,
    message: 'Procedure created successfully',
    data: procedure,
  });
});

// Get all procedures for a clinic
export const getProcedures = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { search, isActive, limit, offset } = req.query;

  const options = {
    search,
    isActive: isActive !== undefined ? isActive === 'true' : undefined,
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const procedures = await Procedure.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: procedures,
    count: procedures.length,
  });
});

// Get a single procedure
export const getProcedure = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const procedure = await Procedure.findById(id, clinicId);

  if (!procedure) {
    return res.status(404).json({
      success: false,
      message: 'Procedure not found',
    });
  }

  res.status(200).json({
    success: true,
    data: procedure,
  });
});

// Get procedure with materials
export const getProcedureWithMaterials = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const procedure = await Procedure.findWithMaterials(id, clinicId);

  if (!procedure) {
    return res.status(404).json({
      success: false,
      message: 'Procedure not found',
    });
  }

  res.status(200).json({
    success: true,
    data: procedure,
  });
});

// Update a procedure
export const updateProcedure = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const procedure = await Procedure.update(id, clinicId, req.body);

  if (!procedure) {
    return res.status(404).json({
      success: false,
      message: 'Procedure not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Procedure updated successfully',
    data: procedure,
  });
});

// Delete a procedure
export const deleteProcedure = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await Procedure.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Procedure not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Procedure deleted successfully',
  });
});

export default {
  createProcedure,
  getProcedures,
  getProcedure,
  getProcedureWithMaterials,
  updateProcedure,
  deleteProcedure,
};

