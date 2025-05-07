import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/stock/presentation/widgets/stock_item_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<StockItemModel> _stockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _stockItems = StockItemModel.getMockStockItems();
      _isLoading = false;
    });
  }

  void _showAddEditStockItemDialog([StockItemModel? item]) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name);
    final descriptionController =
        TextEditingController(text: item?.description);
    final priceController =
        TextEditingController(text: item?.price.toString() ?? '');
    final quantityController =
        TextEditingController(text: item?.quantity.toString() ?? '');
    final unitController = TextEditingController(text: item?.unit);
    final minimumQuantityController =
        TextEditingController(text: item?.minimumQuantity.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Stock Item' : 'Add New Stock Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter item name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter item description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter item price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter current quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'Enter unit (e.g., boxes, bottles)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minimumQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Quantity',
                  hintText: 'Enter minimum quantity for restock alert',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: isEditing ? 'Save Changes' : 'Add Item',
            onPressed: () {
              // TODO: Implement save functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(StockItemModel item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restock Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current quantity: ${item.quantity} ${item.unit}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Add Quantity',
                hintText: 'Enter quantity to add',
                suffixText: item.unit,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Restock',
            onPressed: () {
              // TODO: Implement restock functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(StockItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stock Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Delete',
            variant: ButtonVariant.secondary,
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditStockItemDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stockItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Stock Items Found',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new stock item to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Add Stock Item',
                        onPressed: () => _showAddEditStockItemDialog(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _stockItems.length,
                  itemBuilder: (context, index) {
                    final item = _stockItems[index];
                    return StockItemCard(
                      item: item,
                      onTap: () {
                        // TODO: Navigate to stock item details
                      },
                      onEdit: () => _showAddEditStockItemDialog(item),
                      onDelete: () => _showDeleteConfirmationDialog(item),
                      onRestock: item.needsRestock
                          ? () => _showRestockDialog(item)
                          : null,
                    );
                  },
                ),
    );
  }
}
