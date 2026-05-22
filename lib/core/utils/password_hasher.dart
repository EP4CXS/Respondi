import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _hash(password, salt);
    return '$salt:$hash';
  }

  static bool verify(String password, String stored) {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    return _hash(password, parts[0]) == parts[1];
  }

  static String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
