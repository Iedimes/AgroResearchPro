import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';

class TrialPicker extends ConsumerWidget {
  const TrialPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Trial? value;
  final ValueChanged<Trial?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trials = ref.watch(trialsProvider);
    return trials.when(
      data: (list) {
        if (list.isEmpty) {
          return const Text(
            'No hay ensayos disponibles. Cree uno en "Gestión de Ensayos".',
            style: TextStyle(color: Colors.orange),
          );
        }
        return DropdownButtonFormField<Trial>(
          decoration: const InputDecoration(labelText: 'Ensayo asociado'),
          value: value != null && list.any((t) => t.id == value!.id)
              ? value
              : null,
          items: list
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Seleccione un ensayo' : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar ensayos'),
    );
  }
}
