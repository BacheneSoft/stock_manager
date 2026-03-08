import 'dart:convert';
import '../core/config/app_config.dart';
// Note: secrets.dart is in .gitignore and contains productionObfuscatedKeys
// For the public repo, we use a fallback list.
import '../core/config/secrets.dart' as secrets;

const List<String> _demoKeys = [
  'REVNTy1LRVktMjAyNg==', // DEMO-KEY-2026
];

Set<String> get validActivationKeys {
  if (AppConfig.isDemoMode) {
    return _demoKeys.map((k) => utf8.decode(base64.decode(k))).toSet();
  }

  // Use production keys from secrets.dart
  return secrets.productionObfuscatedKeys
      .map((k) => utf8.decode(base64.decode(k)))
      .toSet();
}

/// Check if a key is a test key
bool isTestKey(String key) {
  if (AppConfig.isDemoMode) return false;
  return secrets.productionTestKeysExpiration.containsKey(key);
}

/// Get expiration duration in minutes for a test key
int? getTestKeyExpirationMinutes(String key) {
  if (AppConfig.isDemoMode) return null;
  return secrets.productionTestKeysExpiration[key];
}
