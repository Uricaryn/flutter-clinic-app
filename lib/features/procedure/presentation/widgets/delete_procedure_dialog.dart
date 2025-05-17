import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteProcedureDialog extends ConsumerStatefulWidget {
  final ProcedureModel procedure;

  const DeleteProcedureDialog({
    super.key,
    required this.procedure,
  });

  @override
  ConsumerState<DeleteProcedureDialog> createState() =>
      _DeleteProcedureDialogState();
}

class _DeleteProcedureDialogState extends ConsumerState<DeleteProcedureDialog> {
  bool _isLoading = false;

  Future<void> _deleteProcedure() async {
    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('procedures')
          .doc(widget.procedure.id)
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
      title: Text(l10n.deleteProcedure),
      content: Text(
        l10n.deleteProcedureConfirmation(widget.procedure.name),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteProcedure,
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(l10n.delete),
        ),
      ],
    );
  }
}
