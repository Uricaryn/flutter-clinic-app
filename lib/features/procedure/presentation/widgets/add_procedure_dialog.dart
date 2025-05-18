import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';

class AddProcedureDialog extends ConsumerStatefulWidget {
  const AddProcedureDialog({super.key});

  @override
  ConsumerState<AddProcedureDialog> createState() => _AddProcedureDialogState();
}

class _AddProcedureDialogState extends ConsumerState<AddProcedureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final List<ProcedureMaterial> _materials = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addMaterial() {
    showDialog(
      context: context,
      builder: (context) => _AddMaterialDialog(
        onAdd: (material) {
          setState(() {
            _materials.add(material);
          });
        },
      ),
    );
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
    });
  }

  Future<void> _saveProcedure() async {
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
      final procedure = ProcedureModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        durationMinutes: int.parse(_durationController.text),
        clinicId: clinicId,
        createdAt: DateTime.now(),
        materials: _materials,
      );

      await firestore
          .collection('procedures')
          .doc(procedure.id)
          .set(procedure.toJson());

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
                l10n.addProcedure,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.procedureName,
                  hintText: l10n.enterProcedureName,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterProcedureName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.enterProcedureDescription,
                ),
                maxLines: 3,
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
                  hintText: l10n.enterProcedurePrice,
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
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: l10n.duration,
                  hintText: l10n.enterProcedureDuration,
                  suffixText: l10n.minutes,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterDuration;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.pleaseEnterValidDuration;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.materials,
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: _addMaterial,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_materials.isNotEmpty) ...[
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return ListTile(
                      title: Text(material.stockItemName),
                      subtitle: Text(
                        '${material.quantity} ${material.unit}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeMaterial(index),
                      ),
                    );
                  },
                ),
              ],
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
                    onPressed: _isLoading ? null : _saveProcedure,
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

class _AddMaterialDialog extends ConsumerStatefulWidget {
  final Function(ProcedureMaterial) onAdd;

  const _AddMaterialDialog({required this.onAdd});

  @override
  ConsumerState<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends ConsumerState<_AddMaterialDialog> {
  String? _selectedStockItemId;
  String? _selectedStockItemName;
  final _quantityController = TextEditingController();
  String? _selectedUnit;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stockItems = ref.watch(stockItemsStreamProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addMaterial,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            stockItems.when(
              data: (snapshot) {
                final items = snapshot.docs;
                return DropdownButtonFormField<String>(
                  value: _selectedStockItemId,
                  decoration: InputDecoration(
                    labelText: l10n.selectStockItem,
                  ),
                  items: items.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final item = items.firstWhere((doc) => doc.id == value);
                      final data = item.data() as Map<String, dynamic>;
                      setState(() {
                        _selectedStockItemId = value;
                        _selectedStockItemName = data['name'] as String;
                        _selectedUnit = data['unit'] as String;
                      });
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Hata: $e'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: l10n.quantity,
                hintText: l10n.enterQuantity,
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedStockItemId == null ||
                        _selectedStockItemName == null ||
                        _selectedUnit == null ||
                        _quantityController.text.isEmpty) {
                      return;
                    }

                    widget.onAdd(
                      ProcedureMaterial(
                        stockItemId: _selectedStockItemId!,
                        stockItemName: _selectedStockItemName!,
                        quantity: int.parse(_quantityController.text),
                        unit: _selectedUnit!,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 