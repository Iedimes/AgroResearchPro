import 'dart:async';

import 'package:agro_research_pro/services/storage/hive_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/base_entity.dart';

class Repository<T extends StorableEntity> {
  Repository(this.boxName, this.fromJson);

  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;

  Future<Box<Map<String, dynamic>>> _box() => HiveStorage.openBox(boxName);

  Future<List<T>> getAll() async {
    final box = await _box();
    final list = box.values
        .map((m) => fromJson(Map<String, dynamic>.from(m)))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<T?> getById(String id) async {
    final box = await _box();
    final raw = box.get(id);
    if (raw == null) return null;
    return fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> put(T entity) async {
    final box = await _box();
    await box.put(entity.id, entity.toJson());
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<int> count() async {
    final box = await _box();
    return box.length;
  }

  Stream<List<T>> watchAll() async* {
    final box = await _box();
    List<T> current() => box.values
        .map((m) => fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    yield current();
    await for (final _ in box.watch()) {
      yield current();
    }
  }
}
