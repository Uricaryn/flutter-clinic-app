import Appointment from '../models/Appointment.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new appointment
export const createAppointment = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const appointmentData = {
    ...req.body,
    clinicId,
  };

  const appointment = await Appointment.create(appointmentData);

  res.status(201).json({
    success: true,
    message: 'Appointment created successfully',
    data: appointment,
  });
});

// Get all appointments for a clinic
export const getAppointments = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { startDate, endDate, status, patientId, limit, offset } = req.query;

  const options = {
    startDate,
    endDate,
    status,
    patientId,
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const appointments = await Appointment.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: appointments,
    count: appointments.length,
  });
});

// Get upcoming appointments
export const getUpcomingAppointments = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;

  const appointments = await Appointment.findUpcoming(clinicId);

  res.status(200).json({
    success: true,
    data: appointments,
    count: appointments.length,
  });
});

// Get a single appointment
export const getAppointment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const appointment = await Appointment.findById(id, clinicId);

  if (!appointment) {
    return res.status(404).json({
      success: false,
      message: 'Appointment not found',
    });
  }

  res.status(200).json({
    success: true,
    data: appointment,
  });
});

// Update an appointment
export const updateAppointment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const appointment = await Appointment.update(id, clinicId, req.body);

  if (!appointment) {
    return res.status(404).json({
      success: false,
      message: 'Appointment not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Appointment updated successfully',
    data: appointment,
  });
});

// Delete an appointment
export const deleteAppointment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await Appointment.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Appointment not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Appointment deleted successfully',
  });
});

// Get appointment statistics
export const getAppointmentStatistics = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({
      success: false,
      message: 'Start date and end date are required',
    });
  }

  const statistics = await Appointment.getStatistics(clinicId, startDate, endDate);

  res.status(200).json({
    success: true,
    data: statistics,
  });
});

export default {
  createAppointment,
  getAppointments,
  getUpcomingAppointments,
  getAppointment,
  updateAppointment,
  deleteAppointment,
  getAppointmentStatistics,
};
