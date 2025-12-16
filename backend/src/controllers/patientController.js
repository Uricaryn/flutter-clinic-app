import Patient from '../models/Patient.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new patient
export const createPatient = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const patientData = {
    ...req.body,
    clinicId,
  };

  const patient = await Patient.create(patientData);

  res.status(201).json({
    success: true,
    message: 'Patient created successfully',
    data: patient,
  });
});

// Get all patients for a clinic
export const getPatients = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { search, limit, offset } = req.query;

  const options = {
    search,
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const patients = await Patient.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: patients,
    count: patients.length,
  });
});

// Get a single patient
export const getPatient = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const patient = await Patient.findById(id, clinicId);

  if (!patient) {
    return res.status(404).json({
      success: false,
      message: 'Patient not found',
    });
  }

  res.status(200).json({
    success: true,
    data: patient,
  });
});

// Get patient with appointment history
export const getPatientWithAppointments = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const patient = await Patient.findWithAppointments(id, clinicId);

  if (!patient) {
    return res.status(404).json({
      success: false,
      message: 'Patient not found',
    });
  }

  res.status(200).json({
    success: true,
    data: patient,
  });
});

// Update a patient
export const updatePatient = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const patient = await Patient.update(id, clinicId, req.body);

  if (!patient) {
    return res.status(404).json({
      success: false,
      message: 'Patient not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Patient updated successfully',
    data: patient,
  });
});

// Delete a patient
export const deletePatient = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await Patient.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Patient not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Patient deleted successfully',
  });
});

export default {
  createPatient,
  getPatients,
  getPatient,
  getPatientWithAppointments,
  updatePatient,
  deletePatient,
};
