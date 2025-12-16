import express from 'express';
import { body } from 'express-validator';
import * as stockController from '../controllers/stockController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createStockItemValidation = [
  body('name').trim().notEmpty().withMessage('Stock item name is required'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('cost').optional().isFloat({ min: 0 }).withMessage('Cost must be a positive number'),
  body('quantity').optional().isInt({ min: 0 }).withMessage('Quantity must be a non-negative integer'),
  body('minimumQuantity').optional().isInt({ min: 0 }).withMessage('Minimum quantity must be a non-negative integer'),
];

const updateQuantityValidation = [
  body('quantityChange').isInt().withMessage('Quantity change must be an integer'),
];

// Routes
router.get('/', stockController.getStockItems);
router.get('/low-stock', stockController.getLowStockItems);
router.get('/:id', stockController.getStockItem);
router.post('/', createStockItemValidation, validate, stockController.createStockItem);
router.put('/:id', stockController.updateStockItem);
router.patch('/:id/quantity', updateQuantityValidation, validate, stockController.updateStockQuantity);
router.delete('/:id', stockController.deleteStockItem);

export default router;

