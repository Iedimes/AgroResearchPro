import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/experimental_application.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';
import 'package:agro_research_pro/widgets/trial_picker.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  const ApplicationFormScreen({super.key, this.application});
  final ExperimentalApplication? application;

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Trial? _trial;
  ApplicationType _type = ApplicationType.experimentalBar;
  late TextEditingController _productCtrl;
  late TextEditingController _doseCtrl;
  late TextEditingController _doseUnitCtrl;
  late TextEditingController _brothCtrl;
  late TextEditingController _plotCtrl;
  late TextEditingController _operatorCtrl;
  late TextEditingController _notesCtrl;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final a = widget.application;
    _type = a?.type ?? ApplicationType.experimentalBar;
    _productCtrl = TextEditingController(text: a?.product ?? '');
    _doseCtrl = TextEditingController(text: a != null ? a.dose.toString() : '');
    _doseUnitCtrl = TextEditingController(text: a?.doseUnit ?? 'L/ha');
    _brothCtrl =
        TextEditingController(text: a != null ? a.brothVolume.toString() : '');
    _plotCtrl = TextEditingController(text: a?.plot ?? '');
    _operatorCtrl = TextEditingController(text: a?.operator ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _date = a?.applicationDate ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [
      _productCtrl,
      _doseCtrl,
      _doseUnitCtrl,
      _brothCtrl,
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
    final repo = ref.read(applicationRepoProvider);
    final dose = double.tryParse(_doseCtrl.text) ?? 0;
    final broth = double.tryParse(_brothCtrl.text) ?? 0;
    final entity = widget.application == null
        ? ExperimentalApplication.create(
            trialId: _trial!.id,
            trialName: _trial!.name,
            crop: _trial!.crop,
            applicationDate: _date,
            type: _type,
            product: _productCtrl.text,
            dose: dose,
            doseUnit: _doseUnitCtrl.text,
            brothVolume: broth,
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            operator: _operatorCtrl.text.isEmpty ? null : _operatorCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          )
        : widget.application!.copyWith(
            type: _type,
            product: _productCtrl.text,
            dose: dose,
            doseUnit: _doseUnitCtrl.text,
            brothVolume: broth,
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            operator: _operatorCtrl.text.isEmpty ? null : _operatorCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          );
    try {
      await repo.put(entity);
      await ref.read(syncProvider.notifier).syncAll();
      final syncResult = ref.read(syncProvider).lastResult;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              syncResult.isEmpty ? 'Aplicación guardada y sincronizada' : syncResult,
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guardado localmente. Error de sincronización: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application == null
            ? 'Nueva Aplicación'
            : 'Editar Aplicación'),
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
              DropdownButtonFormField<ApplicationType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo de aplicación'),
                items: ApplicationType.values
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de aplicación'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productCtrl,
                decoration:
                    const InputDecoration(labelText: 'Producto / Ingrediente activo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseCtrl,
                      decoration: const InputDecoration(labelText: 'Dosis'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _doseUnitCtrl,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brothCtrl,
                decoration: const InputDecoration(
                    labelText: 'Volumen de caldo (L/ha)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plotCtrl,
                decoration:
                    const InputDecoration(labelText: 'Parcela (opcional)'),
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
