import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/features/clinic/domain/models/expense_model.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final String clinicId;
  final ExpenseModel? expense;

  const AddExpenseDialog({
    super.key,
    required this.clinicId,
    this.expense,
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  String _selectedCategory = 'Diğer';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Kira',
    'Personel',
    'Malzeme',
    'Fatura',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      if (widget.expense!.category == 'Fatura') {
        _invoiceNumberController.text = widget.expense!.invoiceNumber ?? '';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final expense = ExpenseModel(
        id: widget.expense?.id ?? '',
        clinicId: widget.clinicId,
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        invoiceNumber: _selectedCategory == 'Fatura'
            ? _invoiceNumberController.text
            : null,
      );

      if (widget.expense == null) {
        // Yeni gider ekle
        final docRef = await FirebaseFirestore.instance
            .collection('expenses')
            .add(expense.toJson());
        await docRef.update({'id': docRef.id});
      } else {
        // Mevcut gideri güncelle
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(widget.expense!.id)
            .update(expense.toJson());
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.expense == null ? 'Yeni Gider Ekle' : 'Gideri Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  border: OutlineInputBorder(),
                  prefixText: '₺',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir tutar girin';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir tutar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              if (_selectedCategory == 'Fatura') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Fatura Numarası',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedCategory == 'Fatura' &&
                        (value == null || value.isEmpty)) {
                      return 'Lütfen fatura numarası girin';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: Text(widget.expense == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }
}
