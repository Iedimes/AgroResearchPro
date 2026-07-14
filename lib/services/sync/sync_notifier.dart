import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agro_research_pro/models/base_entity.dart';
import 'package:agro_research_pro/core/constants/crops.dart';
import 'package:agro_research_pro/services/repository/providers.dart';
import 'package:agro_research_pro/services/repository/generic_repository.dart';
import 'package:agro_research_pro/services/sync/providers.dart';
import 'sync_service.dart';

class SyncState {
  const SyncState({this.syncing = false, this.lastResult = ''});
  final bool syncing;
  final String lastResult;

  SyncState copyWith({bool? syncing, String? lastResult}) => SyncState(
        syncing: syncing ?? this.syncing,
        lastResult: lastResult ?? this.lastResult,
      );
}

Future<void> _syncRepo<T extends StorableEntity>(
  Repository<T> repo,
  SyncService sync,
) async {
  final items = await repo.getAll();
  for (final item in items) {
    if (item.syncStatus != SyncStatus.synced) {
      final synced = item.withSyncStatus(SyncStatus.synced) as T;
      await sync.upload(synced);
      await repo.put(synced);
    }
  }
}

/// Mezcla lo que hay en la nube con lo local: agrega lo que falta localmente y
/// actualiza solo si la versión de la nube es más reciente. Nunca borra lo local.
Future<void> _pullRepo<T extends StorableEntity>(
  Repository<T> repo,
  String collection,
  SyncService sync,
) async {
  final remote = await sync.fetchCollection(collection);
  for (final m in remote) {
    final entity = repo.fromJson(m);
    final local = await repo.getById(entity.id);
    if (local == null || entity.updatedAt.isAfter(local.updatedAt)) {
      await repo.put(entity.withSyncStatus(SyncStatus.synced) as T);
    }
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this.ref) : super(const SyncState());
  final Ref ref;

  Future<void> syncAll() async {
    final sync = ref.read(syncServiceProvider);
    if (!sync.isConfigured) {
      state = state.copyWith(
        syncing: false,
        lastResult: 'Firebase no configurado: los datos siguen solo en este '
            'dispositivo',
      );
      return;
    }
    if (state.syncing) return;
    state = state.copyWith(syncing: true, lastResult: '');
    try {
      await Future.sync(() async {
        // 1) Subir lo local pendiente
        await _syncRepo(ref.read(trialRepoProvider), sync);
        await _syncRepo(ref.read(diseaseRepoProvider), sync);
        await _syncRepo(ref.read(applicationRepoProvider), sync);
        await _syncRepo(ref.read(maintenanceRepoProvider), sync);
        await _syncRepo(ref.read(labRepoProvider), sync);

        // 2) Bajar de la nube y mezclar (recupera lo local y lo alinea con la nube)
        await _pullRepo(ref.read(trialRepoProvider), 'trials', sync);
        await _pullRepo(ref.read(diseaseRepoProvider), 'diseases', sync);
        await _pullRepo(ref.read(applicationRepoProvider), 'applications', sync);
        await _pullRepo(ref.read(maintenanceRepoProvider), 'maintenance', sync);
        await _pullRepo(ref.read(labRepoProvider), 'lab_results', sync);
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('La nube no respondió (20 s)'),
      );
      state = state.copyWith(
        syncing: false,
        lastResult: 'Sincronizado: local y nube alineados',
      );
    } catch (e) {
      state = state.copyWith(syncing: false, lastResult: 'Error: $e');
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(ref),
);
