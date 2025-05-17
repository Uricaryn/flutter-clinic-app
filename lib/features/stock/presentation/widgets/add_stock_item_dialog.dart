import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';

class AddStockItemDialog extends ConsumerStatefulWidget {
  const AddStockItemDialog({super.key});

  @override
  ConsumerState<AddStockItemDialog> createState() => _AddStockItemDialogState();
}

class _AddStockItemDialogState extends ConsumerState<AddStockItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _minimumQuantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _minimumQuantityController.dispose();
    super.dispose();
  }

  Future<void> _saveStockItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Kullanıcı bulunamadı');
      final firestore = FirebaseFirestore.instance;
      final clinicDoc = await firestore
          .collection('clinics')
          .where('ownerId', isEqualTo: user.uid)
          .get();
      if (clinicDoc.docs.isEmpty) {
        throw Exception('Klinik bulunamadı');
      }
      final clinicId = clinicDoc.docs.first.id;
      final now = DateTime.now();
      final stockItem = StockItemModel(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        minimumQuantity: int.parse(_minimumQuantityController.text),
        clinicId: clinicId,
        lastRestocked: now,
        createdAt: now,
        updatedAt: null,
      );
      await firestore
          .collection('stock_items')
          .doc(stockItem.id)
          .set(stockItem.toJson());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addNewStockItem,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  hintText: l10n.enterItemName,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.enterItemDescription,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.price,
                  hintText: l10n.enterItemPrice,
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterPrice;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidPrice;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  hintText: l10n.enterCurrentQuantity,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterQuantity;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.pleaseEnterValidQuantity;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: l10n.unit,
                  hintText: l10n.enterUnit,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterQuantity;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minimumQuantityController,
                decoration: InputDecoration(
                  labelText: l10n.minimumQuantity,
                  hintText: l10n.enterMinimumQuantity,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterQuantity;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.pleaseEnterValidQuantity;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveStockItem,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.saveChanges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
