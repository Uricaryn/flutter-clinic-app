import express from 'express';
import { body } from 'express-validator';
import * as expenseController from '../controllers/expenseController.js';
import { authenticate, requireClinic } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// All routes require authentication and clinic membership
router.use(authenticate);
router.use(requireClinic);

// Validation rules
const createExpenseValidation = [
  body('title').trim().notEmpty().withMessage('Expense title is required'),
  body('amount').isFloat({ min: 0 }).withMessage('Amount must be a positive number'),
  body('date').isISO8601().withMessage('Invalid date format'),
  body('category').optional().trim(),
];

// Routes
router.get('/', expenseController.getExpenses);
router.get('/summary', expenseController.getExpenseSummary);
router.get('/total', expenseController.getTotalExpenses);
router.get('/:id', expenseController.getExpense);
router.post('/', createExpenseValidation, validate, expenseController.createExpense);
router.put('/:id', expenseController.updateExpense);
router.delete('/:id', expenseController.deleteExpense);

export default router;
