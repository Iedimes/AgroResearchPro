import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/disease_assessment.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';
import 'package:agro_research_pro/widgets/trial_picker.dart';

class DiseaseFormScreen extends ConsumerStatefulWidget {
  const DiseaseFormScreen({super.key, this.assessment});
  final DiseaseAssessment? assessment;

  @override
  ConsumerState<DiseaseFormScreen> createState() => _DiseaseFormScreenState();
}

class _DiseaseFormScreenState extends ConsumerState<DiseaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Trial? _trial;
  late TextEditingController _diseaseCtrl;
  late TextEditingController _severityCtrl;
  late TextEditingController _incidenceCtrl;
  late TextEditingController _plotCtrl;
  late TextEditingController _notesCtrl;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final a = widget.assessment;
    _diseaseCtrl = TextEditingController(text: a?.disease ?? '');
    _severityCtrl =
        TextEditingController(text: a != null ? a.severity.toString() : '');
    _incidenceCtrl =
        TextEditingController(text: a != null ? a.incidence.toString() : '');
    _plotCtrl = TextEditingController(text: a?.plot ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _date = a?.evaluationDate ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [_diseaseCtrl, _severityCtrl, _incidenceCtrl, _plotCtrl, _notesCtrl]) {
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

  String? _validatePercent(String? v) {
    if (v == null || v.isEmpty) return 'Requerido';
    final n = double.tryParse(v);
    if (n == null) return 'Debe ser numérico';
    if (n < 0 || n > 100) return 'Entre 0 y 100';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_trial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un ensayo')),
      );
      return;
    }
    final repo = ref.read(diseaseRepoProvider);
    final entity = widget.assessment == null
        ? DiseaseAssessment.create(
            trialId: _trial!.id,
            trialName: _trial!.name,
            crop: _trial!.crop,
            evaluationDate: _date,
            disease: _diseaseCtrl.text,
            severity: double.parse(_severityCtrl.text),
            incidence: double.parse(_incidenceCtrl.text),
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          )
        : widget.assessment!.copyWith(
            disease: _diseaseCtrl.text,
            severity: double.parse(_severityCtrl.text),
            incidence: double.parse(_incidenceCtrl.text),
            plot: _plotCtrl.text.isEmpty ? null : _plotCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          );
    try {
      await repo.put(entity);
      ref.invalidate(diseasesProvider);
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
        title: Text(widget.assessment == null
            ? 'Nueva Evaluación'
            : 'Editar Evaluación'),
        actions: widget.assessment != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar'),
                        content: const Text('¿Confirma que desea eliminar esta evaluación?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      ref.read(diseaseRepoProvider).delete(widget.assessment!.id);
                      ref.invalidate(diseasesProvider);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ]
            : null,
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de evaluación'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diseaseCtrl,
                decoration: const InputDecoration(
                    labelText: 'Enfermedad (ej: Roya, Mancha ojo de rana)'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _severityCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Severidad %', suffixText: '%'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePercent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _incidenceCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Incidencia %', suffixText: '%'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePercent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plotCtrl,
                decoration:
                    const InputDecoration(labelText: 'Parcela / Repetición (opcional)'),
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
