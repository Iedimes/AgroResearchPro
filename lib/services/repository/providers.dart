import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/models/disease_assessment.dart';
import 'package:agro_research_pro/models/experimental_application.dart';
import 'package:agro_research_pro/models/maintenance_log.dart';
import 'package:agro_research_pro/models/lab_result.dart';
import 'package:agro_research_pro/services/repository/generic_repository.dart';

final trialRepoProvider = Provider<Repository<Trial>>(
  (ref) => Repository<Trial>('trials', Trial.fromJson),
);

final diseaseRepoProvider = Provider<Repository<DiseaseAssessment>>(
  (ref) => Repository<DiseaseAssessment>('diseases', DiseaseAssessment.fromJson),
);

final applicationRepoProvider = Provider<Repository<ExperimentalApplication>>(
  (ref) =>
      Repository<ExperimentalApplication>('applications', ExperimentalApplication.fromJson),
);

final maintenanceRepoProvider = Provider<Repository<MaintenanceLog>>(
  (ref) => Repository<MaintenanceLog>('maintenance', MaintenanceLog.fromJson),
);

final labRepoProvider = Provider<Repository<LabResult>>(
  (ref) => Repository<LabResult>('lab_results', LabResult.fromJson),
);

final trialsProvider = StreamProvider<List<Trial>>(
  (ref) => ref.watch(trialRepoProvider).watchAll(),
);

final diseasesProvider = StreamProvider<List<DiseaseAssessment>>(
  (ref) => ref.watch(diseaseRepoProvider).watchAll(),
);

final applicationsProvider = StreamProvider<List<ExperimentalApplication>>(
  (ref) => ref.watch(applicationRepoProvider).watchAll(),
);

final maintenanceProvider = StreamProvider<List<MaintenanceLog>>(
  (ref) => ref.watch(maintenanceRepoProvider).watchAll(),
);

final labResultsProvider = StreamProvider<List<LabResult>>(
  (ref) => ref.watch(labRepoProvider).watchAll(),
);
