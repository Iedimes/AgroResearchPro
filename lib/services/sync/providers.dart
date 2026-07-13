import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_service.dart';
import 'local_only_sync_service.dart';

final syncServiceProvider = Provider<SyncService>(
  (ref) => LocalOnlySyncService(),
);
