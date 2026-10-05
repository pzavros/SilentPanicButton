import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_data.dart';
import 'core/services/location_service.dart';
import 'core/services/battery_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/share_service.dart';
import 'features/home/home_page.dart';

class SilentPanicApp extends StatelessWidget {
  final StorageService storageService;

  const SilentPanicApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        Provider<BatteryService>(
          create: (_) => BatteryService(),
        ),
        Provider<StorageService>.value(
          value: storageService,
        ),
        Provider<ShareService>(
          create: (_) => ShareService(),
        ),
      ],
      child: MaterialApp(
        title: 'Silent Panic Button',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
