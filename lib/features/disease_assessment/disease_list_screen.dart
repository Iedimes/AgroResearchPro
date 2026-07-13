import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/disease_assessment.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/widgets/entity_list_screen.dart';
import 'disease_form_screen.dart';

class DiseaseListScreen extends ConsumerWidget {
  const DiseaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<DiseaseAssessment>(
      title: 'Evaluación de Enfermedades',
      itemsProvider: diseasesProvider,
      fabLabel: 'Nueva evaluación',
      emptyMessage: 'No hay evaluaciones registradas.',
      formBuilder: (a) => DiseaseFormScreen(assessment: a),
      onDelete: (a) => ref.read(diseaseRepoProvider).delete(a.id),
      cardBuilder: (context, a) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: const Icon(Icons.bug_report, color: Colors.red),
        ),
        title: Text(a.disease, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${a.crop.label} • ${a.trialName}'),
            Text(
                'Sev: ${a.severity.toStringAsFixed(1)}% | Inc: ${a.incidence.toStringAsFixed(1)}%'),
            Text(
              '${formatDate(a.evaluationDate)} • ${a.syncStatus.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
