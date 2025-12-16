import Clinic from '../models/Clinic.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new clinic
export const createClinic = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const clinicData = {
    ...req.body,
    ownerId,
  };

  const clinic = await Clinic.create(clinicData);

  res.status(201).json({
    success: true,
    message: 'Clinic created successfully',
    data: clinic,
  });
});

// Get all clinics
export const getClinics = asyncHandler(async (req, res) => {
  const clinics = await Clinic.findAll();

  res.status(200).json({
    success: true,
    data: clinics,
    count: clinics.length,
  });
});

// Get a single clinic
export const getClinic = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const clinic = await Clinic.findById(id);

  if (!clinic) {
    return res.status(404).json({
      success: false,
      message: 'Clinic not found',
    });
  }

  res.status(200).json({
    success: true,
    data: clinic,
  });
});

// Get clinic statistics
export const getClinicStatistics = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const clinic = await Clinic.findById(id);
  if (!clinic) {
    return res.status(404).json({
      success: false,
      message: 'Clinic not found',
    });
  }

  const statistics = await Clinic.getStatistics(id);

  res.status(200).json({
    success: true,
    data: statistics,
  });
});

// Update a clinic
export const updateClinic = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const clinic = await Clinic.update(id, req.body);

  if (!clinic) {
    return res.status(404).json({
      success: false,
      message: 'Clinic not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Clinic updated successfully',
    data: clinic,
  });
});

// Delete a clinic (soft delete)
export const deleteClinic = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const result = await Clinic.delete(id);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Clinic not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Clinic deleted successfully',
  });
});

export default {
  createClinic,
  getClinics,
  getClinic,
  getClinicStatistics,
  updateClinic,
  deleteClinic,
};
