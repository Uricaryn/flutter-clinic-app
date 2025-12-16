import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestockItemDialog extends ConsumerStatefulWidget {
  final StockItemModel stockItem;

  const RestockItemDialog({
    super.key,
    required this.stockItem,
  });

  @override
  ConsumerState<RestockItemDialog> createState() => _RestockItemDialogState();
}

class _RestockItemDialogState extends ConsumerState<RestockItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _restockItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final addedQuantity = int.parse(_quantityController.text);
      final newQuantity = widget.stockItem.quantity + addedQuantity;

      await firestore.collection('stock_items').doc(widget.stockItem.id).update({
        'quantity': newQuantity,
        'lastRestocked': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.stockItem.name} başarıyla yenilendi! Yeni miktar: $newQuantity ${widget.stockItem.unit}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.restockItem,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stockItem.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mevcut Miktar:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${widget.stockItem.quantity} ${widget.stockItem.unit}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.stockItem.needsRestock
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum Miktar:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${widget.stockItem.minimumQuantity} ${widget.stockItem.unit}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Eklenecek Miktar',
                  hintText: 'Stoka eklenecek miktarı giriniz',
                  prefixIcon: const Icon(Icons.add_circle_outline),
                  suffixText: widget.stockItem.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Örn: ${widget.stockItem.minimumQuantity * 2}',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen eklenecek miktarı giriniz';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null) {
                    return 'Lütfen geçerli bir sayı giriniz';
                  }
                  if (quantity <= 0) {
                    return 'Miktar 0\'dan büyük olmalıdır';
                  }
                  return null;
                },
              ),
              if (_quantityController.text.isNotEmpty &&
                  int.tryParse(_quantityController.text) != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yeni Toplam:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.stockItem.quantity + int.parse(_quantityController.text)} ${widget.stockItem.unit}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _restockItem,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'İşleniyor...' : 'Stoğu Yenile'),
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


