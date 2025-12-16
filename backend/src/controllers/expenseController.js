import Expense from '../models/Expense.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new expense
export const createExpense = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const expenseData = {
    ...req.body,
    clinicId,
  };

  const expense = await Expense.create(expenseData);

  res.status(201).json({
    success: true,
    message: 'Expense created successfully',
    data: expense,
  });
});

// Get all expenses for a clinic
export const getExpenses = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { search, category, startDate, endDate, limit, offset } = req.query;

  const options = {
    search,
    category,
    startDate,
    endDate,
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const expenses = await Expense.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: expenses,
    count: expenses.length,
  });
});

// Get a single expense
export const getExpense = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const expense = await Expense.findById(id, clinicId);

  if (!expense) {
    return res.status(404).json({
      success: false,
      message: 'Expense not found',
    });
  }

  res.status(200).json({
    success: true,
    data: expense,
  });
});

// Get expense summary by category
export const getExpenseSummary = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({
      success: false,
      message: 'Start date and end date are required',
    });
  }

  const summary = await Expense.getSummaryByCategory(clinicId, startDate, endDate);

  res.status(200).json({
    success: true,
    data: summary,
  });
});

// Get total expenses for a period
export const getTotalExpenses = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({
      success: false,
      message: 'Start date and end date are required',
    });
  }

  const total = await Expense.getTotalExpenses(clinicId, startDate, endDate);

  res.status(200).json({
    success: true,
    data: total,
  });
});

// Update an expense
export const updateExpense = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const expense = await Expense.update(id, clinicId, req.body);

  if (!expense) {
    return res.status(404).json({
      success: false,
      message: 'Expense not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Expense updated successfully',
    data: expense,
  });
});

// Delete an expense
export const deleteExpense = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await Expense.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Expense not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Expense deleted successfully',
  });
});

export default {
  createExpense,
  getExpenses,
  getExpense,
  getExpenseSummary,
  getTotalExpenses,
  updateExpense,
  deleteExpense,
};

