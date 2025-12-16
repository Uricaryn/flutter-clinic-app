import express from 'express';
import { body } from 'express-validator';
import * as procedureController from '../controllers/procedureController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createProcedureValidation = [
  body('name').trim().notEmpty().withMessage('Procedure name is required'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('durationMinutes').optional().isInt({ min: 1 }).withMessage('Duration must be a positive integer'),
];

// Routes
router.get('/', procedureController.getProcedures);
router.get('/:id', procedureController.getProcedure);
router.get('/:id/materials', procedureController.getProcedureWithMaterials);
router.post('/', createProcedureValidation, validate, procedureController.createProcedure);
router.put('/:id', procedureController.updateProcedure);
router.delete('/:id', procedureController.deleteProcedure);

export default router;
