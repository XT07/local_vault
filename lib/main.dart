import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/user_profile.dart';
import 'services/settings_service.dart';
import 'services/profile_service.dart';
import 'services/migration_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  await ProfileService.openBox();

  await MigrationService().runMigrations();

  final settings = SettingsService();
  await settings.load();

  runApp(
    ChangeNotifierProvider<SettingsService>.value(
      value: settings,
      child: const LocalVaultApp(),
    ),
  );
}

class LocalVaultApp extends StatelessWidget {
  const LocalVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: 'LocalVault',
      debugShowCheckedModeBanner: false,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
