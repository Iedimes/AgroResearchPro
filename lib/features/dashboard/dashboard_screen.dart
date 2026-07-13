import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:agro_research_pro/models/disease_assessment.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/sync/sync_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Trial? _selectedTrial;

  Future<void> _sync() async {
    await ref.read(syncProvider.notifier).syncAll();
    if (mounted) {
      final msg = ref.read(syncProvider).lastResult;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trials = ref.watch(trialsProvider);
    final diseases = ref.watch(diseasesProvider);
    final applications = ref.watch(applicationsProvider);
    final maintenance = ref.watch(maintenanceProvider);
    final labResults = ref.watch(labResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Investigación'),
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
                  onPressed: _sync,
                ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatGrid(
            context,
            trials: trials.maybeWhen(data: (d) => d.length, orElse: () => 0),
            diseases: diseases.maybeWhen(data: (d) => d.length, orElse: () => 0),
            applications:
                applications.maybeWhen(data: (d) => d.length, orElse: () => 0),
            maintenance:
                maintenance.maybeWhen(data: (d) => d.length, orElse: () => 0),
            lab: labResults.maybeWhen(data: (d) => d.length, orElse: () => 0),
          ),
          const SizedBox(height: 24),
          trials.when(
            data: (list) {
              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Cree un ensayo para ver la evolución de severidad de enfermedades.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              _selectedTrial ??= list.first;
              final filtered = diseases.maybeWhen(
                data: (d) => d
                    .where((e) => e.trialId == _selectedTrial!.id)
                    .toList()
                  ..sort((a, b) => a.evaluationDate.compareTo(b.evaluationDate)),
                orElse: () => <DiseaseAssessment>[],
              );
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Trial>(
                              decoration: const InputDecoration(
                                  labelText: 'Ensayo',
                                  border: OutlineInputBorder()),
                              value: _selectedTrial != null &&
                                      list.any((t) => t.id == _selectedTrial!.id)
                                  ? _selectedTrial
                                  : null,
                              items: list
                                  .map((t) => DropdownMenuItem(
                                      value: t, child: Text(t.name)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedTrial = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Evolución de Severidad (% en el tiempo)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: _SeverityChart(evaluations: filtered),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          diseases.when(
            data: (list) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Evaluaciones por enfermedad',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _DiseaseBarChart(evaluations: list),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(
    BuildContext context, {
    required int trials,
    required int diseases,
    required int applications,
    required int maintenance,
    required int lab,
  }) {
    final stats = [
      _Stat(label: 'Ensayos', value: trials, color: Colors.green, icon: Icons.grass),
      _Stat(label: 'Evaluaciones', value: diseases, color: Colors.red, icon: Icons.bug_report),
      _Stat(label: 'Aplicaciones', value: applications, color: Colors.purple, icon: Icons.science),
      _Stat(label: 'Mantenimiento', value: maintenance, color: Colors.teal, icon: Icons.shield),
      _Stat(label: 'Laboratorio', value: lab, color: Colors.blue, icon: Icons.biotech),
    ];
    final vw = MediaQuery.of(context).size.width;
    final cardW = vw > 600 ? 150.0 : (vw - 32 - 12) / 2;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map((s) => SizedBox(
                width: cardW,
                child: Card(
                  color: s.color.withOpacity(0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: s.color),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${s.value}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Text(s.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;
}

class _SeverityChart extends StatelessWidget {
  const _SeverityChart({required this.evaluations});
  final List<DiseaseAssessment> evaluations;

  @override
  Widget build(BuildContext context) {
    if (evaluations.isEmpty) {
      return const Center(
          child: Text('Sin evaluaciones para este ensayo',
              style: TextStyle(color: Colors.grey)));
    }
    final spots = evaluations
        .asMap()
        .map((i, e) => MapEntry(i, FlSpot(i.toDouble(), e.severity)))
        .values
        .toList();
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= evaluations.length) return const Text('');
                return Text(formatDate(evaluations[idx].evaluationDate),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                  style: const TextStyle(fontSize: 10)),
              reservedSize: 36,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true, color: Colors.red.withOpacity(0.15)),
          ),
        ],
      ),
    );
  }
}

class _DiseaseBarChart extends StatelessWidget {
  const _DiseaseBarChart({required this.evaluations});
  final List<DiseaseAssessment> evaluations;

  @override
  Widget build(BuildContext context) {
    if (evaluations.isEmpty) {
      return const Center(
          child: Text('Sin evaluaciones registradas',
              style: TextStyle(color: Colors.grey)));
    }
    final counts = <String, int>{};
    for (final e in evaluations) {
      counts[e.disease] = (counts[e.disease] ?? 0) + 1;
    }
    final entries = counts.entries.toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) return const Text('');
                final name = entries[idx].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(name.length > 10 ? '${name.substring(0, 10)}…' : name,
                      style: const TextStyle(fontSize: 9),
                      textAlign: TextAlign.center),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text('${v.toInt()}',
                  style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries
            .asMap()
            .map((i, e) => MapEntry(
                  i,
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: Colors.orange,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }
}
