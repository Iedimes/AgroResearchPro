import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/base_entity.dart';

class DiseaseAssessment implements StorableEntity {
  const DiseaseAssessment({
    required this.id,
    required this.trialId,
    required this.trialName,
    required this.crop,
    required this.evaluationDate,
    required this.disease,
    required this.severity,
    required this.incidence,
    this.plot,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });

  @override
  final String id;
  final String trialId;
  final String trialName;
  final Crop crop;
  final DateTime evaluationDate;
  final String disease;
  final double severity; // escala 0-100 (% de área afectada)
  final double incidence; // % de plantas afectadas
  final String? plot;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;

  DiseaseAssessment copyWith({
    String? disease,
    double? severity,
    double? incidence,
    String? plot,
    String? notes,
    SyncStatus? syncStatus,
  }) =>
      DiseaseAssessment(
        id: id,
        trialId: trialId,
        trialName: trialName,
        crop: crop,
        evaluationDate: evaluationDate,
        disease: disease ?? this.disease,
        severity: severity ?? this.severity,
        incidence: incidence ?? this.incidence,
        plot: plot ?? this.plot,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? SyncStatus.pending,
      );

  @override
  StorableEntity withSyncStatus(SyncStatus status) => copyWith(syncStatus: status);

  factory DiseaseAssessment.create({
    required String trialId,
    required String trialName,
    required Crop crop,
    required DateTime evaluationDate,
    required String disease,
    required double severity,
    required double incidence,
    String? plot,
    String? notes,
  }) {
    final now = DateTime.now();
    return DiseaseAssessment(
      id: generateId(),
      trialId: trialId,
      trialName: trialName,
      crop: crop,
      evaluationDate: evaluationDate,
      disease: disease,
      severity: severity,
      incidence: incidence,
      plot: plot,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'trialId': trialId,
        'trialName': trialName,
        'crop': crop.id,
        'evaluationDate': evaluationDate.toIso8601String(),
        'disease': disease,
        'severity': severity,
        'incidence': incidence,
        'plot': plot,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.id,
      };

  factory DiseaseAssessment.fromJson(Map<String, dynamic> json) =>
      DiseaseAssessment(
        id: json['id'] as String,
        trialId: json['trialId'] as String,
        trialName: json['trialName'] as String,
        crop: Crop.fromId(json['crop'] as String),
        evaluationDate: DateTime.parse(json['evaluationDate'] as String),
        disease: json['disease'] as String,
        severity: (json['severity'] as num).toDouble(),
        incidence: (json['incidence'] as num).toDouble(),
        plot: json['plot'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.fromId(json['syncStatus'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DiseaseAssessment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
