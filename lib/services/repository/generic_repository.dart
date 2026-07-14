import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:agro_research_pro/services/storage/hive_storage.dart';
import '../../models/base_entity.dart';

class Repository<T extends StorableEntity> {
  Repository(this.boxName, this.fromJson);

  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;

  final Map<String, Map<String, dynamic>> _cache = {};
  bool _cacheLoaded = false;
  Future<void>? _loadFuture;

  Future<void> _ensureLoaded() async {
    if (_cacheLoaded) return;
    if (_loadFuture != null) return _loadFuture;
    _loadFuture = _loadAll();
    await _loadFuture;
    _cacheLoaded = true;
    _loadFuture = null;
  }

  Future<void> _loadAll() async {
    final box = await HiveStorage.openBox(boxName);
    try {
      await Future.sync(() async {
        for (final value in box.values) {
          final m = Map<String, dynamic>.from(value);
          _cache[m['id'] as String] = m;
        }
      }).timeout(const Duration(seconds: 5));
    } catch (_) {
      // cache queda vacío: la app funciona igual sin datos persistidos
    }
  }

  Future<Box<Map<String, dynamic>>> _box() => HiveStorage.openBox(boxName);

  Future<List<T>> getAll() async {
    await _ensureLoaded();
    final list = _cache.values
        .map((m) => fromJson(Map<String, dynamic>.from(m)))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<T?> getById(String id) async {
    await _ensureLoaded();
    final raw = _cache[id];
    if (raw == null) return null;
    return fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> put(T entity) async {
    await _ensureLoaded();
    final json = entity.toJson();
    _cache[entity.id] = json;
    try {
      await _box().then((b) => b.put(entity.id, json))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // persistencia opcional: cache ya tiene el dato
    }
  }

  Future<void> delete(String id) async {
    await _ensureLoaded();
    _cache.remove(id);
    try {
      await _box().then((b) => b.delete(id))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // persistencia opcional
    }
  }

  Future<int> count() async {
    await _ensureLoaded();
    return _cache.length;
  }

  Stream<List<T>> watchAll() async* {
    await _ensureLoaded();
    List<T> current() => _cache.values
        .map((m) => fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    yield current();
    await for (final _ in (await _box()).watch()) {
      yield current();
    }
  }
}
