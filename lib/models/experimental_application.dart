import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/base_entity.dart';

enum ApplicationType {
  experimentalBar('experimentalBar', 'Barra experimental'),
  fungicide('fungicide', 'Fungicida'),
  fertilizer('fertilizer', 'Fertilizante'),
  other('other', 'Otro');

  const ApplicationType(this.id, this.label);
  final String id;
  final String label;
  static ApplicationType fromId(String? id) => ApplicationType.values.firstWhere(
        (e) => e.id == id,
        orElse: () => ApplicationType.experimentalBar,
      );
}

class ExperimentalApplication implements StorableEntity {
  const ExperimentalApplication({
    required this.id,
    required this.trialId,
    required this.trialName,
    required this.crop,
    required this.applicationDate,
    required this.type,
    required this.product,
    required this.dose,
    required this.doseUnit,
    required this.brothVolume,
    this.plot,
    this.operator,
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
  final DateTime applicationDate;
  final ApplicationType type;
  final String product;
  final double dose; // dosis por hectárea
  final String doseUnit; // ej: L/ha, kg/ha, g/ha
  final double brothVolume; // L/ha de caldo
  final String? plot;
  final String? operator;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;

  ExperimentalApplication copyWith({
    ApplicationType? type,
    String? product,
    double? dose,
    String? doseUnit,
    double? brothVolume,
    String? plot,
    String? operator,
    String? notes,
    SyncStatus? syncStatus,
  }) =>
      ExperimentalApplication(
        id: id,
        trialId: trialId,
        trialName: trialName,
        crop: crop,
        applicationDate: applicationDate,
        type: type ?? this.type,
        product: product ?? this.product,
        dose: dose ?? this.dose,
        doseUnit: doseUnit ?? this.doseUnit,
        brothVolume: brothVolume ?? this.brothVolume,
        plot: plot ?? this.plot,
        operator: operator ?? this.operator,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? SyncStatus.pending,
      );

  @override
  StorableEntity withSyncStatus(SyncStatus status) => copyWith(syncStatus: status);

  factory ExperimentalApplication.create({
    required String trialId,
    required String trialName,
    required Crop crop,
    required DateTime applicationDate,
    required ApplicationType type,
    required String product,
    required double dose,
    required String doseUnit,
    required double brothVolume,
    String? plot,
    String? operator,
    String? notes,
  }) {
    final now = DateTime.now();
    return ExperimentalApplication(
      id: generateId(),
      trialId: trialId,
      trialName: trialName,
      crop: crop,
      applicationDate: applicationDate,
      type: type,
      product: product,
      dose: dose,
      doseUnit: doseUnit,
      brothVolume: brothVolume,
      plot: plot,
      operator: operator,
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
        'applicationDate': applicationDate.toIso8601String(),
        'type': type.id,
        'product': product,
        'dose': dose,
        'doseUnit': doseUnit,
        'brothVolume': brothVolume,
        'plot': plot,
        'operator': operator,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.id,
      };

  factory ExperimentalApplication.fromJson(Map<String, dynamic> json) =>
      ExperimentalApplication(
        id: json['id'] as String,
        trialId: json['trialId'] as String,
        trialName: json['trialName'] as String,
        crop: Crop.fromId(json['crop'] as String),
        applicationDate: DateTime.parse(json['applicationDate'] as String),
        type: ApplicationType.fromId(json['type'] as String?),
        product: json['product'] as String,
        dose: (json['dose'] as num).toDouble(),
        doseUnit: json['doseUnit'] as String,
        brothVolume: (json['brothVolume'] as num).toDouble(),
        plot: json['plot'] as String?,
        operator: json['operator'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.fromId(json['syncStatus'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentalApplication && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
