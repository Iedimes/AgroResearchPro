import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/base_entity.dart';

class LabResult implements StorableEntity {
  const LabResult({
    required this.id,
    required this.sampleCode,
    required this.crop,
    required this.receptionDate,
    required this.analysis,
    required this.parameter,
    required this.value,
    required this.unit,
    this.laboratory,
    this.trialId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });

  @override
  final String id;
  final String sampleCode;
  final Crop crop;
  final DateTime receptionDate;
  final String analysis; // ej: Análisis de suelo, calidad de semilla
  final String parameter; // ej: pH, N, P, K, proteína
  final double value;
  final String unit;
  final String? laboratory;
  final String? trialId;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;

  LabResult copyWith({
    String? sampleCode,
    Crop? crop,
    String? analysis,
    String? parameter,
    double? value,
    String? unit,
    String? laboratory,
    String? notes,
    SyncStatus? syncStatus,
  }) =>
      LabResult(
        id: id,
        sampleCode: sampleCode ?? this.sampleCode,
        crop: crop ?? this.crop,
        receptionDate: receptionDate,
        analysis: analysis ?? this.analysis,
        parameter: parameter ?? this.parameter,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        laboratory: laboratory ?? this.laboratory,
        trialId: trialId,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? SyncStatus.pending,
      );

  @override
  StorableEntity withSyncStatus(SyncStatus status) => copyWith(syncStatus: status);

  factory LabResult.create({
    required String sampleCode,
    required Crop crop,
    required DateTime receptionDate,
    required String analysis,
    required String parameter,
    required double value,
    required String unit,
    String? laboratory,
    String? trialId,
    String? notes,
  }) {
    final now = DateTime.now();
    return LabResult(
      id: generateId(),
      sampleCode: sampleCode,
      crop: crop,
      receptionDate: receptionDate,
      analysis: analysis,
      parameter: parameter,
      value: value,
      unit: unit,
      laboratory: laboratory,
      trialId: trialId,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'sampleCode': sampleCode,
        'crop': crop.id,
        'receptionDate': receptionDate.toIso8601String(),
        'analysis': analysis,
        'parameter': parameter,
        'value': value,
        'unit': unit,
        'laboratory': laboratory,
        'trialId': trialId,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.id,
      };

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        id: json['id'] as String,
        sampleCode: json['sampleCode'] as String,
        crop: Crop.fromId(json['crop'] as String),
        receptionDate: DateTime.parse(json['receptionDate'] as String),
        analysis: json['analysis'] as String,
        parameter: json['parameter'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        laboratory: json['laboratory'] as String?,
        trialId: json['trialId'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.fromId(json['syncStatus'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LabResult && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
