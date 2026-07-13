import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/base_entity.dart';

enum MaintenanceActionType {
  pestControl('pestControl', 'Control de plaga'),
  sanitation('sanitation', 'Limpieza / Saneamiento'),
  irrigation('irrigation', 'Riego'),
  fertilization('fertilization', 'Fertilización'),
  other('other', 'Otro');

  const MaintenanceActionType(this.id, this.label);
  final String id;
  final String label;
  static MaintenanceActionType fromId(String? id) =>
      MaintenanceActionType.values.firstWhere(
        (e) => e.id == id,
        orElse: () => MaintenanceActionType.pestControl,
      );
}

class MaintenanceLog implements StorableEntity {
  const MaintenanceLog({
    required this.id,
    required this.trialId,
    required this.trialName,
    required this.crop,
    required this.actionDate,
    required this.type,
    this.pest,
    this.product,
    this.dose,
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
  final DateTime actionDate;
  final MaintenanceActionType type;
  final String? pest;
  final String? product;
  final String? dose;
  final String? plot;
  final String? operator;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;

  MaintenanceLog copyWith({
    MaintenanceActionType? type,
    String? pest,
    String? product,
    String? dose,
    String? plot,
    String? operator,
    String? notes,
    SyncStatus? syncStatus,
  }) =>
      MaintenanceLog(
        id: id,
        trialId: trialId,
        trialName: trialName,
        crop: crop,
        actionDate: actionDate,
        type: type ?? this.type,
        pest: pest ?? this.pest,
        product: product ?? this.product,
        dose: dose ?? this.dose,
        plot: plot ?? this.plot,
        operator: operator ?? this.operator,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? SyncStatus.pending,
      );

  @override
  StorableEntity withSyncStatus(SyncStatus status) => copyWith(syncStatus: status);

  factory MaintenanceLog.create({
    required String trialId,
    required String trialName,
    required Crop crop,
    required DateTime actionDate,
    required MaintenanceActionType type,
    String? pest,
    String? product,
    String? dose,
    String? plot,
    String? operator,
    String? notes,
  }) {
    final now = DateTime.now();
    return MaintenanceLog(
      id: generateId(),
      trialId: trialId,
      trialName: trialName,
      crop: crop,
      actionDate: actionDate,
      type: type,
      pest: pest,
      product: product,
      dose: dose,
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
        'actionDate': actionDate.toIso8601String(),
        'type': type.id,
        'pest': pest,
        'product': product,
        'dose': dose,
        'plot': plot,
        'operator': operator,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.id,
      };

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) => MaintenanceLog(
        id: json['id'] as String,
        trialId: json['trialId'] as String,
        trialName: json['trialName'] as String,
        crop: Crop.fromId(json['crop'] as String),
        actionDate: DateTime.parse(json['actionDate'] as String),
        type: MaintenanceActionType.fromId(json['type'] as String?),
        pest: json['pest'] as String?,
        product: json['product'] as String?,
        dose: json['dose'] as String?,
        plot: json['plot'] as String?,
        operator: json['operator'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.fromId(json['syncStatus'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MaintenanceLog && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
