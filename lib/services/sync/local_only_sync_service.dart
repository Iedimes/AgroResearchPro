import 'package:agro_research_pro/models/base_entity.dart';
import 'sync_service.dart';

/// Implementación offline: la sincronización real se conecta cuando exista
/// la configuración de Firebase (lib/firebase_options.dart).
class LocalOnlySyncService implements SyncService {
  @override
  bool get isConfigured => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> upload(StorableEntity entity) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchCollection(String collection) async =>
      [];
}
