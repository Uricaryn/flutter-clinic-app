import express from 'express';
import { body } from 'express-validator';
import * as appointmentController from '../controllers/appointmentController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createAppointmentValidation = [
  body('patientName').trim().notEmpty().withMessage('Patient name is required'),
  body('dateTime').isISO8601().withMessage('Valid date and time is required'),
  body('status')
    .optional()
    .isIn(['scheduled', 'completed', 'cancelled', 'no_show'])
    .withMessage('Invalid status'),
];

// Routes
router.get('/', appointmentController.getAppointments);
router.get('/upcoming', appointmentController.getUpcomingAppointments);
router.get('/statistics', appointmentController.getAppointmentStatistics);
router.get('/:id', appointmentController.getAppointment);
router.post('/', createAppointmentValidation, validate, appointmentController.createAppointment);
router.put('/:id', appointmentController.updateAppointment);
router.delete('/:id', appointmentController.deleteAppointment);

export default router;
