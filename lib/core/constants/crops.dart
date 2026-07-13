enum Crop {
  soja('soja', 'Soja', 'Glycine max'),
  trigo('trigo', 'Trigo', 'Triticum aestivum'),
  maiz('maiz', 'Maíz', 'Zea mays'),
  sorgo('sorgo', 'Sorgo', 'Sorghum bicolor');

  const Crop(this.id, this.label, this.scientificName);

  final String id;
  final String label;
  final String scientificName;

  static Crop fromId(String id) =>
      Crop.values.firstWhere((c) => c.id == id, orElse: () => Crop.soja);
}

enum SyncStatus {
  local('local', 'Local (sin sincronizar)'),
  synced('synced', 'Sincronizado'),
  pending('pending', 'Pendiente de subida');

  const SyncStatus(this.id, this.label);
  final String id;
  final String label;

  static SyncStatus fromId(String? id) => SyncStatus.values.firstWhere(
        (s) => s.id == id,
        orElse: () => SyncStatus.local,
      );
}
