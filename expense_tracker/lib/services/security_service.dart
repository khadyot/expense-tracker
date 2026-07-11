import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'app_lock_pin_hash';
  static const _passwordKey = 'app_lock_password_hash';

  static String _hash(String value) {
    var bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: _hash(pin));
  }

  static Future<bool> verifyPin(String pin) async {
    String? storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    return storedHash == _hash(pin);
  }

  static Future<void> savePassword(String password) async {
    await _storage.write(key: _passwordKey, value: _hash(password));
  }

  static Future<bool> verifyPassword(String password) async {
    String? storedHash = await _storage.read(key: _passwordKey);
    if (storedHash == null) return false;
    return storedHash == _hash(password);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
