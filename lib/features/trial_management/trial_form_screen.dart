import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';

class TrialFormScreen extends ConsumerStatefulWidget {
  const TrialFormScreen({super.key, this.trial});
  final Trial? trial;

  @override
  ConsumerState<TrialFormScreen> createState() => _TrialFormScreenState();
}

class _TrialFormScreenState extends ConsumerState<TrialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _responsibleCtrl;
  late TextEditingController _objectiveCtrl;
  late TextEditingController _observationsCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _repetitionsCtrl;
  late TextEditingController _plotsCtrl;
  Crop _crop = Crop.soja;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    final t = widget.trial;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _responsibleCtrl = TextEditingController(text: t?.responsible ?? '');
    _objectiveCtrl = TextEditingController(text: t?.objective ?? '');
    _observationsCtrl = TextEditingController(text: t?.observations ?? '');
    _latCtrl = TextEditingController(
        text: t != null ? t.location.latitude.toString() : '');
    _lngCtrl = TextEditingController(
        text: t != null ? t.location.longitude.toString() : '');
    _addressCtrl = TextEditingController(text: t?.location.address ?? '');
    _repetitionsCtrl =
        TextEditingController(text: (t?.repetitions ?? 3).toString());
    _plotsCtrl = TextEditingController(text: (t?.plots ?? 0).toString());
    _crop = t?.crop ?? Crop.soja;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _responsibleCtrl,
      _objectiveCtrl,
      _observationsCtrl,
      _latCtrl,
      _lngCtrl,
      _addressCtrl,
      _repetitionsCtrl,
      _plotsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latCtrl.text = pos.latitude.toStringAsFixed(6);
      _lngCtrl.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener la ubicación: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitud y longitud deben ser numéricas')),
      );
      return;
    }
    final repo = ref.read(trialRepoProvider);
    final location = GeoPoint(
      latitude: lat,
      longitude: lng,
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
    );
    final entity = widget.trial == null
        ? Trial.create(
            name: _nameCtrl.text,
            crop: _crop,
            location: location,
            responsible: _responsibleCtrl.text,
            repetitions: int.tryParse(_repetitionsCtrl.text) ?? 3,
            plots: int.tryParse(_plotsCtrl.text) ?? 0,
            objective: _objectiveCtrl.text.isEmpty ? null : _objectiveCtrl.text,
            observations:
                _observationsCtrl.text.isEmpty ? null : _observationsCtrl.text,
          )
        : widget.trial!.copyWith(
            name: _nameCtrl.text,
            crop: _crop,
            location: location,
            responsible: _responsibleCtrl.text,
            repetitions: int.tryParse(_repetitionsCtrl.text) ?? 3,
            plots: int.tryParse(_plotsCtrl.text) ?? 0,
            objective: _objectiveCtrl.text.isEmpty ? null : _objectiveCtrl.text,
            observations:
                _observationsCtrl.text.isEmpty ? null : _observationsCtrl.text,
          );
    try {
      await repo.put(entity);
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
        title: Text(widget.trial == null ? 'Nuevo Ensayo' : 'Editar Ensayo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del ensayo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Crop>(
                value: _crop,
                decoration: const InputDecoration(labelText: 'Cultivo'),
                items: Crop.values
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _crop = v ?? _crop),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _responsibleCtrl,
                decoration: const InputDecoration(labelText: 'Responsable'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _repetitionsCtrl,
                      decoration: const InputDecoration(labelText: 'Repeticiones'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plotsCtrl,
                      decoration: const InputDecoration(labelText: 'Parcelas'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Ubicación (GPS)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(labelText: 'Latitud'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(labelText: 'Longitud'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _loadingLocation
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton.filled(
                          onPressed: _useMyLocation,
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Usar mi ubicación',
                        ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                decoration:
                    const InputDecoration(labelText: 'Dirección / Lote (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _objectiveCtrl,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationsCtrl,
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
