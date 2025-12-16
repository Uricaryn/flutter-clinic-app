import StockItem from '../models/StockItem.js';
import { asyncHandler } from '../middleware/errorHandler.js';

// Create a new stock item
export const createStockItem = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const stockItemData = {
    ...req.body,
    clinicId,
  };

  const stockItem = await StockItem.create(stockItemData);

  res.status(201).json({
    success: true,
    message: 'Stock item created successfully',
    data: stockItem,
  });
});

// Get all stock items for a clinic
export const getStockItems = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;
  const { search, lowStock, limit, offset } = req.query;

  const options = {
    search,
    lowStock: lowStock === 'true',
    limit: limit ? parseInt(limit) : undefined,
    offset: offset ? parseInt(offset) : undefined,
  };

  const stockItems = await StockItem.findByClinicId(clinicId, options);

  res.status(200).json({
    success: true,
    data: stockItems,
    count: stockItems.length,
  });
});

// Get low stock items
export const getLowStockItems = asyncHandler(async (req, res) => {
  const clinicId = req.user.clinicId;

  const stockItems = await StockItem.getLowStock(clinicId);

  res.status(200).json({
    success: true,
    data: stockItems,
    count: stockItems.length,
  });
});

// Get a single stock item
export const getStockItem = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const stockItem = await StockItem.findById(id, clinicId);

  if (!stockItem) {
    return res.status(404).json({
      success: false,
      message: 'Stock item not found',
    });
  }

  res.status(200).json({
    success: true,
    data: stockItem,
  });
});

// Update a stock item
export const updateStockItem = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const stockItem = await StockItem.update(id, clinicId, req.body);

  if (!stockItem) {
    return res.status(404).json({
      success: false,
      message: 'Stock item not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Stock item updated successfully',
    data: stockItem,
  });
});

// Update stock quantity
export const updateStockQuantity = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;
  const { quantityChange } = req.body;

  if (!quantityChange || isNaN(quantityChange)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid quantity change value',
    });
  }

  const stockItem = await StockItem.updateQuantity(id, clinicId, quantityChange);

  if (!stockItem) {
    return res.status(404).json({
      success: false,
      message: 'Stock item not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Stock quantity updated successfully',
    data: stockItem,
  });
});

// Delete a stock item
export const deleteStockItem = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const clinicId = req.user.clinicId;

  const result = await StockItem.delete(id, clinicId);

  if (!result) {
    return res.status(404).json({
      success: false,
      message: 'Stock item not found',
    });
  }

  res.status(200).json({
    success: true,
    message: 'Stock item deleted successfully',
  });
});

export default {
  createStockItem,
  getStockItems,
  getLowStockItems,
  getStockItem,
  updateStockItem,
  updateStockQuantity,
  deleteStockItem,
};
