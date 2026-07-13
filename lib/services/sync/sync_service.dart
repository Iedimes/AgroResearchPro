import '../../models/base_entity.dart';

abstract class SyncService {
  Future<void> initialize();
  Future<void> upload(StorableEntity entity);

  /// Descarga todos los documentos de una colección de Firestore.
  Future<List<Map<String, dynamic>>> fetchCollection(String collection);

  bool get isConfigured;
}
