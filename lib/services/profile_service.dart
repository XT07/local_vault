import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const _boxName = 'user_profiles';

  Box<UserProfile> get _box => Hive.box<UserProfile>(_boxName);

  static Future<void> openBox() async {
    await Hive.openBox<UserProfile>(_boxName);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put('profile', profile);
  }

  UserProfile? getProfile() {
    return _box.get('profile');
  }

  Future<void> clearProfile() async {
    await _box.delete('profile');
  }
}
