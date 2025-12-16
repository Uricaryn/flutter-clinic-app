import express from 'express';
import { body } from 'express-validator';
import * as patientController from '../controllers/patientController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createPatientValidation = [
  body('fullName').trim().notEmpty().withMessage('Full name is required'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Invalid email address'),
  body('phone').optional().trim(),
  body('dateOfBirth').optional().isISO8601().withMessage('Invalid date format'),
];

// Routes
router.get('/', patientController.getPatients);
router.get('/:id', patientController.getPatient);
router.get('/:id/appointments', patientController.getPatientWithAppointments);
router.post('/', createPatientValidation, validate, patientController.createPatient);
router.put('/:id', patientController.updatePatient);
router.delete('/:id', patientController.deletePatient);

export default router;
