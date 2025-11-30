import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_table_app/core/constants/keys_enums.dart';

class TokenStorage {
  final String _tokenKey = SharedPreferenceKeys.token.name;
  final _secureStorage = FlutterSecureStorage();

  /// Save token, fallback to SharedPreferences if SecureStorage fails
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      // fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  /// Read token (checks secure storage first, then SharedPreferences)
  Future<String?> getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: _tokenKey);
      if (secureToken != null) return secureToken;
    } catch (_) {
      // ignore and try prefs
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Delete token from both storages
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {
      // ignore
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
