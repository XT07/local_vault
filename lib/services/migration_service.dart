import 'package:shared_preferences/shared_preferences.dart';

class MigrationService {
  static const _keyDataVersion = 'data_version';
  static const int _currentVersion = 2;

  Future<void> runMigrations() async {
    final prefs = await SharedPreferences.getInstance();
    final int savedVersion = prefs.getInt(_keyDataVersion) ?? 1;

    if (savedVersion < _currentVersion) {
      await _migrateV1ToV2(prefs);
      await prefs.setInt(_keyDataVersion, _currentVersion);
      print('[MigrationService] Migração concluída: v$savedVersion → v$_currentVersion');
    } else {
      print('[MigrationService] Dados já na versão $_currentVersion. Nenhuma migração necessária.');
    }
  }

  Future<void> _migrateV1ToV2(SharedPreferences prefs) async {
    final oldDarkMode = prefs.getBool('theme_dark');
    if (oldDarkMode != null) {
      await prefs.setBool('dark_mode', oldDarkMode);
      await prefs.remove('theme_dark');
      print('[MigrationService] Migrado: theme_dark → dark_mode');
    }

    final oldLang = prefs.getString('lang');
    if (oldLang != null) {
      await prefs.setString('language', oldLang);
      await prefs.remove('lang');
      print('[MigrationService] Migrado: lang → language');
    }

    final oldNotif = prefs.getBool('notif');
    if (oldNotif != null) {
      await prefs.setBool('notifications', oldNotif);
      await prefs.remove('notif');
      print('[MigrationService] Migrado: notif → notifications');
    }
  }

  Future<int> getCurrentDataVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDataVersion) ?? 1;
  }
}
