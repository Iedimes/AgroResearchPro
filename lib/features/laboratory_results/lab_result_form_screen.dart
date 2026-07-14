import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/lab_result.dart';
import 'package:agro_research_pro/services/repository/providers.dart';

class LabResultFormScreen extends ConsumerStatefulWidget {
  const LabResultFormScreen({super.key, this.result});
  final LabResult? result;

  @override
  ConsumerState<LabResultFormScreen> createState() => _LabResultFormScreenState();
}

class _LabResultFormScreenState extends ConsumerState<LabResultFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sampleCtrl;
  Crop _crop = Crop.soja;
  late TextEditingController _analysisCtrl;
  late TextEditingController _parameterCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _labCtrl;
  late TextEditingController _notesCtrl;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final r = widget.result;
    _sampleCtrl = TextEditingController(text: r?.sampleCode ?? '');
    _crop = r?.crop ?? Crop.soja;
    _analysisCtrl = TextEditingController(text: r?.analysis ?? '');
    _parameterCtrl = TextEditingController(text: r?.parameter ?? '');
    _valueCtrl = TextEditingController(text: r != null ? r.value.toString() : '');
    _unitCtrl = TextEditingController(text: r?.unit ?? '');
    _labCtrl = TextEditingController(text: r?.laboratory ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _date = r?.receptionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [
      _sampleCtrl,
      _analysisCtrl,
      _parameterCtrl,
      _valueCtrl,
      _unitCtrl,
      _labCtrl,
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
    final repo = ref.read(labRepoProvider);
    final value = double.tryParse(_valueCtrl.text) ?? 0;
    final entity = widget.result == null
        ? LabResult.create(
            sampleCode: _sampleCtrl.text,
            crop: _crop,
            receptionDate: _date,
            analysis: _analysisCtrl.text,
            parameter: _parameterCtrl.text,
            value: value,
            unit: _unitCtrl.text,
            laboratory: _labCtrl.text.isEmpty ? null : _labCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          )
        : widget.result!.copyWith(
            sampleCode: _sampleCtrl.text,
            crop: _crop,
            analysis: _analysisCtrl.text,
            parameter: _parameterCtrl.text,
            value: value,
            unit: _unitCtrl.text,
            laboratory: _labCtrl.text.isEmpty ? null : _labCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          );
    try {
      await repo.put(entity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resultado guardado')),
        );
        Navigator.pop(context);
      }
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
        title: Text(widget.result == null ? 'Nuevo Resultado' : 'Editar Resultado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _sampleCtrl,
                decoration: const InputDecoration(labelText: 'Código de muestra'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Crop>(
                value: _crop,
                decoration: const InputDecoration(labelText: 'Cultivo'),
                items: Crop.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _crop = v ?? _crop),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de recepción'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _analysisCtrl,
                decoration: const InputDecoration(labelText: 'Análisis (ej: Calidad de suelo)'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _parameterCtrl,
                      decoration: const InputDecoration(labelText: 'Parámetro'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _valueCtrl,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labCtrl,
                decoration:
                    const InputDecoration(labelText: 'Laboratorio (opcional)'),
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
