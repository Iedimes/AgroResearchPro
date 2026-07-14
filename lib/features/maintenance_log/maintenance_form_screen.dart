import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/maintenance_log.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';
import 'package:agro_research_pro/widgets/trial_picker.dart';

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  const MaintenanceFormScreen({super.key, this.log});
  final MaintenanceLog? log;

  @override
  ConsumerState<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Trial? _trial;
  MaintenanceActionType _type = MaintenanceActionType.pestControl;
  late TextEditingController _pestCtrl;
  late TextEditingController _productCtrl;
  late TextEditingController _doseCtrl;
  late TextEditingController _plotCtrl;
  late TextEditingController _operatorCtrl;
  late TextEditingController _notesCtrl;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final l = widget.log;
    _type = l?.type ?? MaintenanceActionType.pestControl;
    _pestCtrl = TextEditingController(text: l?.pest ?? '');
    _productCtrl = TextEditingController(text: l?.product ?? '');
    _doseCtrl = TextEditingController(text: l?.dose ?? '');
    _plotCtrl = TextEditingController(text: l?.plot ?? '');
    _operatorCtrl = TextEditingController(text: l?.operator ?? '');
    _notesCtrl = TextEditingController(text: l?.notes ?? '');
    _date = l?.actionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [
      _pestCtrl,
      _productCtrl,
      _doseCtrl,
      _plotCtrl,
      _operatorCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_trial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un ensayo')),
      );
      return;
    }
    final repo = ref.read(maintenanceRepoProvider);
    final entity = widget.log == null
        ? MaintenanceLog.create(
            trialId: _trial!.id,
            trialName: _trial!.name,
            crop: _trial!.crop,
            actionDate: _date,
            type: _type,
            pest: _pestCtrl.text.isEmpty ? null : _pestCtrl.text,
            product: _productCtrl.text.isEmpty ? null : _productCtrl.text,
            dose: _doseCtrl.text.isEmpty ? null : _doseCtrl.text,
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            operator: _operatorCtrl.text.isEmpty ? null : _operatorCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          )
        : widget.log!.copyWith(
            type: _type,
            pest: _pestCtrl.text.isEmpty ? null : _pestCtrl.text,
            product: _productCtrl.text.isEmpty ? null : _productCtrl.text,
            dose: _doseCtrl.text.isEmpty ? null : _doseCtrl.text,
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            operator: _operatorCtrl.text.isEmpty ? null : _operatorCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          );
    try {
      await repo.put(entity);
      ref.invalidate(maintenanceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado')),
        );
        Navigator.pop(context);
      }
      unawaited(
        ref
            .read(syncProvider.notifier)
            .syncAll()
            .then((_) {
              final r = ref.read(syncProvider).lastResult;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(r.isEmpty ? 'Sincronizado con la nube' : r),
                  ),
                );
              }
            })
            .catchError((e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se pudo sincronizar: $e')),
                );
              }
            }),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log == null ? 'Nuevo Registro' : 'Editar Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TrialPicker(
                value: _trial,
                onChanged: (t) => setState(() => _trial = t),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MaintenanceActionType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo de acción'),
                items: MaintenanceActionType.values
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pestCtrl,
                decoration: const InputDecoration(
                    labelText: 'Plaga detectada (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productCtrl,
                decoration:
                    const InputDecoration(labelText: 'Producto / Tratamiento'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dosis / Dosis equivalente'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plotCtrl,
                decoration: const InputDecoration(labelText: 'Parcela (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _operatorCtrl,
                decoration: const InputDecoration(labelText: 'Operario (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
