import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agro_research_pro/features/trial_management/trial_list_screen.dart';
import 'package:agro_research_pro/features/dashboard/dashboard_screen.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';
import 'package:agro_research_pro/features/disease_assessment/disease_list_screen.dart';
import 'package:agro_research_pro/features/experimental_control/application_list_screen.dart';
import 'package:agro_research_pro/features/maintenance_log/maintenance_list_screen.dart';
import 'package:agro_research_pro/features/laboratory_results/lab_result_list_screen.dart';

final class AppRouter {
  static final GoRouter routerConfig = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'trial-management',
            builder: (context, state) => const TrialListScreen(),
          ),
          GoRoute(
            path: 'disease-assessment',
            builder: (context, state) => const DiseaseListScreen(),
          ),
          GoRoute(
            path: 'experimental-control',
            builder: (context, state) => const ApplicationListScreen(),
          ),
          GoRoute(
            path: 'maintenance-log',
            builder: (context, state) => const MaintenanceListScreen(),
          ),
          GoRoute(
            path: 'laboratory-results',
            builder: (context, state) => const LabResultListScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _autoSynced = false;

  Future<void> _sync(BuildContext context) async {
    await ref.read(syncProvider.notifier).syncAll();
    if (context.mounted) {
      final msg = ref.read(syncProvider).lastResult;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void initState() {
    super.initState();
    // Al arrancar, sincroniza una vez (sube pendientes y baja lo de la nube).
    Future.microtask(() {
      if (!_autoSynced) {
        _autoSynced = true;
        ref.read(syncProvider.notifier).syncAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleTile(
        title: 'Panel de Investigación',
        subtitle: 'Estadísticas y gráficos',
        icon: Icons.dashboard,
        route: '/dashboard',
      ),
      _ModuleTile(
        title: 'Gestión de Ensayos',
        subtitle: 'Parcelas, GPS y cultivos',
        icon: Icons.grass,
        route: '/trial-management',
      ),
      _ModuleTile(
        title: 'Evaluación de Enfermedades',
        subtitle: 'Incidencia y severidad',
        icon: Icons.bug_report,
        route: '/disease-assessment',
      ),
      _ModuleTile(
        title: 'Control Experimental',
        subtitle: 'Aplicaciones y dosis',
        icon: Icons.science,
        route: '/experimental-control',
      ),
      _ModuleTile(
        title: 'Bitácora de Mantenimiento',
        subtitle: 'Control de plagas',
        icon: Icons.shield,
        route: '/maintenance-log',
      ),
      _ModuleTile(
        title: 'Resultados de Laboratorio',
        subtitle: 'Ensayos fuera de campo',
        icon: Icons.biotech,
        route: '/laboratory-results',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroResearch Pro'),
        actions: [
          ref.watch(syncProvider).syncing
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: 'Sincronizar con la nube',
                  onPressed: () => _sync(context),
                ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = modules[index];
          return Card(
            child: ListTile(
              leading: Icon(m.icon, color: Colors.green.shade700, size: 32),
              title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(m.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(m.route),
            ),
          );
        },
      ),
    );
  }
}

class _ModuleTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _ModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Página no encontrada')),
      );
}
