import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/maintenance_log.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/widgets/entity_list_screen.dart';
import 'maintenance_form_screen.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<MaintenanceLog>(
      title: 'Bitácora de Mantenimiento',
      itemsProvider: maintenanceProvider,
      fabLabel: 'Nuevo registro',
      emptyMessage: 'No hay registros de mantenimiento.',
      formBuilder: (l) => MaintenanceFormScreen(log: l),
      onDelete: (l) => ref.read(maintenanceRepoProvider).delete(l.id),
      cardBuilder: (context, l) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: const Icon(Icons.shield, color: Colors.teal),
        ),
        title: Text(l.type.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.crop.label} • ${l.trialName}'),
            if (l.pest != null) Text('Plaga: ${l.pest}'),
            if (l.product != null) Text('Tratamiento: ${l.product}'),
            Text(
              '${formatDate(l.actionDate)} • ${l.syncStatus.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
