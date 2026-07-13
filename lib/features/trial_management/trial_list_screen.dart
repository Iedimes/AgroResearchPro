import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/widgets/entity_list_screen.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'trial_form_screen.dart';

class TrialListScreen extends ConsumerWidget {
  const TrialListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<Trial>(
      title: 'Gestión de Ensayos',
      itemsProvider: trialsProvider,
      fabLabel: 'Nuevo ensayo',
      emptyMessage:
          'No hay ensayos registrados.\nToque el botón para crear el primero.',
      formBuilder: (trial) => TrialFormScreen(trial: trial),
      onDelete: (trial) => ref.read(trialRepoProvider).delete(trial.id),
      cardBuilder: (context, trial) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.grass, color: Colors.green),
        ),
        title: Text(trial.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${trial.crop.label} • Responsable: ${trial.responsible}'),
            if (trial.location.address != null)
              Text(trial.location.address!, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              'Creado: ${formatDate(trial.createdAt)} • ${trial.syncStatus.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
