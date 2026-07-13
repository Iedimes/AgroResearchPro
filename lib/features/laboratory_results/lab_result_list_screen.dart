import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/lab_result.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/widgets/entity_list_screen.dart';
import 'lab_result_form_screen.dart';

class LabResultListScreen extends ConsumerWidget {
  const LabResultListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<LabResult>(
      title: 'Resultados de Laboratorio',
      itemsProvider: labResultsProvider,
      fabLabel: 'Nuevo resultado',
      emptyMessage: 'No hay resultados de laboratorio registrados.',
      formBuilder: (r) => LabResultFormScreen(result: r),
      onDelete: (r) => ref.read(labRepoProvider).delete(r.id),
      cardBuilder: (context, r) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.biotech, color: Colors.blue),
        ),
        title: Text('${r.parameter}: ${r.value} ${r.unit}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${r.crop.label} • ${r.analysis} • Muestra ${r.sampleCode}'),
            if (r.laboratory != null) Text('Lab: ${r.laboratory}'),
            Text(
              '${formatDate(r.receptionDate)} • ${r.syncStatus.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
