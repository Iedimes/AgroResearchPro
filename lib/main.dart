import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/storage/hive_storage.dart';
import 'services/sync/firebase_sync_service.dart';
import 'services/sync/local_only_sync_service.dart';
import 'services/sync/sync_service.dart';
import 'services/sync/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();

  SyncService syncService = LocalOnlySyncService();
  try {
    syncService = await FirebaseSyncService.create();
  } catch (e) {
    syncService = LocalOnlySyncService();
  }

  runApp(
    ProviderScope(
      overrides: [syncServiceProvider.overrideWithValue(syncService)],
      child: const AgroResearchProApp(),
    ),
  );
}

class AgroResearchProApp extends StatelessWidget {
  const AgroResearchProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgroResearch Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.routerConfig,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
        Locale('fr', ''),
      ],
    );
  }
}
