import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteStockItemDialog extends ConsumerStatefulWidget {
  final StockItemModel stockItem;

  const DeleteStockItemDialog({
    super.key,
    required this.stockItem,
  });

  @override
  ConsumerState<DeleteStockItemDialog> createState() =>
      _DeleteStockItemDialogState();
}

class _DeleteStockItemDialogState extends ConsumerState<DeleteStockItemDialog> {
  bool _isLoading = false;

  Future<void> _deleteStockItem() async {
    setState(() => _isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('stock_items')
          .doc(widget.stockItem.id)
          .delete();
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
    return AlertDialog(
      title: Text(l10n.deleteStockItem),
      content: Text(l10n.deleteConfirmation(widget.stockItem.name)),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteStockItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.delete),
        ),
      ],
    );
  }
}
