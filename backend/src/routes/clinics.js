import express from 'express';
import { body } from 'express-validator';
import * as clinicController from '../controllers/clinicController.js';
import { authenticate } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// Validation rules
const createClinicValidation = [
  body('name').trim().notEmpty().withMessage('Clinic name is required'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Invalid email address'),
  body('phone').optional().trim(),
  body('specialization').optional().trim(),
];

// Public routes (no authentication required)
router.get('/', clinicController.getClinics);
router.get('/:id', clinicController.getClinic);

// Protected routes (authentication required)
router.use(authenticate);

router.post('/', createClinicValidation, validate, clinicController.createClinic);
router.get('/:id/statistics', clinicController.getClinicStatistics);
router.put('/:id', clinicController.updateClinic);
router.delete('/:id', clinicController.deleteClinic);

export default router;

