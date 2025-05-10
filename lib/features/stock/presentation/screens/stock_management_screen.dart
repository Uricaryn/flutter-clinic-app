import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/stock/presentation/widgets/stock_item_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? l10n.editStockItem : l10n.addNewStockItem),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  hintText: l10n.enterItemName,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.enterItemDescription,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: l10n.price,
                  hintText: l10n.enterItemPrice,
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  hintText: l10n.enterCurrentQuantity,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  labelText: l10n.unit,
                  hintText: l10n.enterUnit,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minimumQuantityController,
                decoration: InputDecoration(
                  labelText: l10n.minimumQuantity,
                  hintText: l10n.enterMinimumQuantity,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          CustomButton(
            text: isEditing ? l10n.saveChanges : l10n.addStockItem,
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restockItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentQuantity(item.quantity, item.unit),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: l10n.addQuantity,
                hintText: l10n.enterQuantityToAdd,
                suffixText: item.unit,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          CustomButton(
            text: l10n.restock,
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteStockItem),
        content: Text(l10n.deleteConfirmation(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          CustomButton(
            text: l10n.delete,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockManagement),
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
                        l10n.noStockItemsFound,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addStockItemToStart,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: l10n.addStockItem,
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
