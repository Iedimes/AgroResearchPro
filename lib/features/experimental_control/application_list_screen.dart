import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/experimental_application.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/widgets/entity_list_screen.dart';
import 'application_form_screen.dart';

class ApplicationListScreen extends ConsumerWidget {
  const ApplicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<ExperimentalApplication>(
      title: 'Control Experimental',
      itemsProvider: applicationsProvider,
      fabLabel: 'Nueva aplicación',
      emptyMessage: 'No hay aplicaciones registradas.',
      formBuilder: (a) => ApplicationFormScreen(application: a),
      onDelete: (a) => ref.read(applicationRepoProvider).delete(a.id),
      cardBuilder: (context, a) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: const Icon(Icons.science, color: Colors.purple),
        ),
        title: Text(a.product, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${a.type.label} • ${a.crop.label} • ${a.trialName}'),
            Text('${a.dose} ${a.doseUnit}  |  Caldo: ${a.brothVolume} L/ha'),
            Text(
              '${formatDate(a.applicationDate)} • ${a.syncStatus.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
