import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_research_pro/firebase_options.dart';
import 'package:agro_research_pro/models/base_entity.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/models/disease_assessment.dart';
import 'package:agro_research_pro/models/experimental_application.dart';
import 'package:agro_research_pro/models/maintenance_log.dart';
import 'package:agro_research_pro/models/lab_result.dart';
import 'sync_service.dart';

/// Sincronización real con Firebase (Firestore + Auth anónimo).
class FirebaseSyncService implements SyncService {
  FirebaseSyncService(this._firestore);

  final FirebaseFirestore _firestore;

  static Future<FirebaseSyncService> create() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    return FirebaseSyncService(FirebaseFirestore.instance);
  }

  String _collectionName(StorableEntity entity) {
    if (entity is Trial) return 'trials';
    if (entity is DiseaseAssessment) return 'diseases';
    if (entity is ExperimentalApplication) return 'applications';
    if (entity is MaintenanceLog) return 'maintenance';
    if (entity is LabResult) return 'lab_results';
    return 'entities';
  }

  @override
  bool get isConfigured => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> upload(StorableEntity entity) async {
    await _firestore
        .collection(_collectionName(entity))
        .doc(entity.id)
        .set(entity.toJson());
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCollection(String collection) async {
    final snap = await _firestore.collection(collection).get();
    return snap.docs.map((d) => Map<String, dynamic>.from(d.data())).toList();
  }
}
