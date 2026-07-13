import 'package:agro_research_pro/core/constants/crops.dart';

abstract class StorableEntity {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  SyncStatus get syncStatus;

  Map<String, dynamic> toJson();

  StorableEntity withSyncStatus(SyncStatus status);
}

abstract class StorableEntityCompanion {
  String get boxName;
}
