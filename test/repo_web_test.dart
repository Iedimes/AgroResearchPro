import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:agro_research_pro/services/repository/generic_repository.dart';
import 'package:agro_research_pro/services/storage/hive_storage.dart';
import 'package:agro_research_pro/models/trial.dart';
import 'package:agro_research_pro/core/constants/crops.dart';

void main() {
  setUpAll(() async {
    await HiveStorage.init();
    // limpia cajas de prueba
    if (Hive.isBoxOpen('test_trials')) await Hive.box('test_trials').clear();
  });

  test('put + getAll devuelve el registro guardado', () async {
    final repo = Repository<Trial>('test_trials', Trial.fromJson);
    final trial = Trial.create(
      name: 'Web Test',
      crop: Crop.soja,
      location: const GeoPoint(latitude: -34.6, longitude: -58.4),
      responsible: 'Tester',
    );
    final id = trial.id;

    await repo.put(trial);
    final all = await repo.getAll();

    expect(all.length, 1);
    expect(all.first.name, 'Web Test');
    expect(all.first.id, id);

    await repo.delete(id);
  });

  test('put con campos null', () async {
    final repo = Repository<Trial>('test_trials', Trial.fromJson);
    final trial = Trial.create(
      name: 'NullFields',
      crop: Crop.trigo,
      location: const GeoPoint(latitude: 0.0, longitude: 0.0),
      responsible: 'Test',
      objective: null,
      observations: null,
    );

    await repo.put(trial);
    final all = await repo.getAll();
    expect(all.any((e) => e.id == trial.id), true, reason: 'registro con null debería estar en getAll');

    await repo.delete(trial.id);
  });

  test('getAll vacio despues de delete', () async {
    final repo = Repository<Trial>('test_trials', Trial.fromJson);
    final trial = Trial.create(
      name: 'DeleteTest',
      crop: Crop.maiz,
      location: const GeoPoint(latitude: -31.0, longitude: -60.0),
      responsible: 'Test',
    );

    await repo.put(trial);
    await repo.delete(trial.id);
    final all = await repo.getAll();
    expect(all.any((e) => e.id == trial.id), false, reason: 'registro borrado no debería estar en getAll');
  });
}
