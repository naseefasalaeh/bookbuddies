import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _userKey = 'current_user';

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUser = preferences.getString(_userKey);

    if (rawUser == null) return null;

    try {
      return Map<String, dynamic>.from(jsonDecode(rawUser));
    } on FormatException {
      await preferences.remove(_userKey);
      return null;
    }
  }

  static Future<int?> getUserId() async {
    final user = await getUser();
    return int.tryParse(user?['id']?.toString() ?? '');
  }

  static Future<String> getRole() async {
    final user = await getUser();
    return user?['role']?.toString().toLowerCase() ?? 'user';
  }

  static Future<bool> isAdmin() async => await getRole() == 'admin';

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userKey);
  }
}
