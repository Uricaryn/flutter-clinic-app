import express from 'express';
import { body } from 'express-validator';
import * as operatorController from '../controllers/operatorController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createOperatorValidation = [
  body('name').trim().notEmpty().withMessage('Operator name is required'),
  body('email').isEmail().normalizeEmail().withMessage('Invalid email address'),
  body('phone').optional().trim(),
  body('role').optional().trim(),
];

// Routes
router.get('/', operatorController.getOperators);
router.get('/:id', operatorController.getOperator);
router.get('/:id/appointments', operatorController.getOperatorWithAppointments);
router.post('/', createOperatorValidation, validate, operatorController.createOperator);
router.put('/:id', operatorController.updateOperator);
router.delete('/:id', operatorController.deleteOperator);

export default router;
