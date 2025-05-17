import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/stock/presentation/widgets/stock_item_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/shared/widgets/auth_background.dart';
import 'package:clinic_app/features/stock/presentation/widgets/edit_stock_item_dialog.dart';
import 'package:clinic_app/features/stock/presentation/widgets/delete_stock_item_dialog.dart';
import 'package:clinic_app/features/stock/presentation/widgets/add_stock_item_dialog.dart';

class StockManagementScreen extends ConsumerWidget {
  const StockManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final asyncStock = ref.watch(stockItemsStreamProvider);

    return Scaffold(
      body: AuthBackground(
        showMedicalIcons: false,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.stockManagement,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: asyncStock.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ).animate().fadeIn().scale(),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noStockItemsFound,
                              style: theme.textTheme.titleLarge,
                            ).animate().fadeIn().slideY(),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addStockItemToStart,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ).animate().fadeIn().slideY(),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: l10n.addStockItem,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const AddStockItemDialog(),
                                );
                              },
                            ).animate().fadeIn().scale(),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final item = StockItemModel.fromJson(data);
                        return StockItemCard(
                          item: item,
                          onTap: () {
                            // TODO: Navigate to stock item details
                          },
                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditStockItemDialog(stockItem: item),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DeleteStockItemDialog(stockItem: item),
                            );
                          },
                          onRestock: item.needsRestock
                              ? () {
                                  // TODO: Stok yenileme dialogu
                                }
                              : null,
                        ).animate().fadeIn().slideX();
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddStockItemDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
