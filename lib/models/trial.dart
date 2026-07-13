import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/core/utils/app_utils.dart';
import 'package:agro_research_pro/models/base_entity.dart';

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude, this.address});
  final double latitude;
  final double longitude;
  final String? address;

  GeoPoint copyWith({double? latitude, double? longitude, String? address}) =>
      GeoPoint(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
      );
}

class Trial implements StorableEntity {
  const Trial({
    required this.id,
    required this.name,
    required this.crop,
    required this.location,
    required this.responsible,
    this.repetitions = 3,
    this.plots = 0,
    this.objective,
    this.observations,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
  });

  @override
  final String id;
  final String name;
  final Crop crop;
  final GeoPoint location;
  final String responsible;
  final int repetitions;
  final int plots;
  final String? objective;
  final String? observations;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;

  Trial copyWith({
    String? name,
    Crop? crop,
    GeoPoint? location,
    String? responsible,
    int? repetitions,
    int? plots,
    String? objective,
    String? observations,
    SyncStatus? syncStatus,
  }) =>
      Trial(
        id: id,
        name: name ?? this.name,
        crop: crop ?? this.crop,
        location: location ?? this.location,
        responsible: responsible ?? this.responsible,
        repetitions: repetitions ?? this.repetitions,
        plots: plots ?? this.plots,
        objective: objective ?? this.objective,
        observations: observations ?? this.observations,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        syncStatus: syncStatus ?? SyncStatus.pending,
      );

  @override
  StorableEntity withSyncStatus(SyncStatus status) => copyWith(syncStatus: status);

  factory Trial.create({
    required String name,
    required Crop crop,
    required GeoPoint location,
    required String responsible,
    int repetitions = 3,
    int plots = 0,
    String? objective,
    String? observations,
  }) {
    final now = DateTime.now();
    return Trial(
      id: generateId(),
      name: name,
      crop: crop,
      location: location,
      responsible: responsible,
      repetitions: repetitions,
      plots: plots,
        objective: objective,
        observations: observations,
        createdAt: now,
        updatedAt: now,
      );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'crop': crop.id,
        'location': location.toJson(),
        'responsible': responsible,
        'repetitions': repetitions,
        'plots': plots,
        'objective': objective,
        'observations': observations,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.id,
      };

  factory Trial.fromJson(Map<String, dynamic> json) => Trial(
        id: json['id'] as String,
        name: json['name'] as String,
        crop: Crop.fromId(json['crop'] as String),
        location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
        responsible: json['responsible'] as String,
        repetitions: json['repetitions'] as int? ?? 3,
        plots: json['plots'] as int? ?? 0,
        objective: json['objective'] as String?,
        observations: json['observations'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.fromId(json['syncStatus'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Trial && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
