import 'dart:convert';

const List<String> _obfuscatedKeys = [
  // Added new keys below
  'TTlOUC1DNFRTLTdUSDItVzNFSA==',
  // Test keys - 2 days expiration (10 keys)
  'OEY0QS05UzJDLTdCMUUtM0Y2QQ==', // 8F4A-9S2C-7B1E-3F6A used
  'QzFFNy01QTlGLTJBNEQtMEU4Qw==', // C1E7-5A9F-2A4D-0E8C
  'NkIyRC0zVjhBLUE5QzQtMUU3Qg==', // 6B2D-3V8A-A9C4-1E7B
  'RjBBMy03RzFCLTlENUUtMkI2Rg==', // F0A3-7G1B-9D5E-2B6F
  'QTlEOC00VDJDLTZFMUYtM0MwQQ==', // A9D8-4T2C-6E1F-3C0A
  'M0U3Qi0xQTRBLThGMkQtOUE1Qw==', // 3E7B-1A4A-8F2D-9A5C
  'RDJDNi0wVDlBLTVCM0UtN0ExRA==', // D2C6-0T9A-5B3E-7A1D
  'NUExRi04SDNELTJFN0ItNEQ5QQ==', // 5A1F-8H3D-2E7B-4D9A
  'QjdFNC0yQjlDLTBENkYtMUM4Qg==', // B7E4-2B9C-0D6F-1C8B
  'NEM5Qi03RTJBLTNGMUQtOEIwRQ==', // 4C9B-7E2A-3F1D-8B0E
  // Test key - 10 minutes expiration (for quick testing)
  'TTlOUC1DNFRTLTdUSDItVzRFWA==', // 10-minute key
  // Production keys:
  'QzFFNy03RzJCLTJBNEQtOEIwRQ==', // C1E7-7G2B-2A4D-8B0E
  'NUIzRS0zVjRBLUMxRTctMUU3Qg==', // 5B3E-3V4A-C1E7-1E7B
  'RjBBMy1EMkM2LTZENUUtMEQ2Rg==', // F0A3-D2C6-6D5E-0D6F
  'QTlEOC03RTJBLTBENEYtM0MwQQ==', // A9D8-7E2A-0D4F-3C0A
  'NEQ5QS0xQTRBLTJGMkQtM0YxRA==', // 4D9A-1A4A-2F2D-3F1D
  'MFQ5QS04SDlELTdFMkEtN0ExRA==', // 0T9A-8H9D-7E2A-7A1D
  'NEQ5QS04SDJELTFDOEItQjdFNA==', // 4D9A-8H2D-1C8B-B7E4
  'QjdFNC0yQjhDLTBENkYtMUM4Qg==', // B7E4-2B8C-0D6F-1C8B
  'QTlEOC03RTJBLUQyQzktMEQ2Rg==', // A9D8-7E2A-D2C9-0D6F
  'NEM5Qi03RTJBLTBENkYtN0E0QQ==', // 4C9B-7E2A-0D6F-7A4A
  'MUE0QS0wRDZGLTNGMUQtRDJDOQ==', // 1A4A-0D6F-3F1D-D2C9
  'N0UyQS03RzFCLTNGMUQtRDJDNw==', // 7E2A-7G1B-3F1D-D2C7
];

// Map of test keys to their expiration duration in minutes
final Map<String, int> _testKeysExpiration = {
  // 2 days keys
  utf8.decode(base64.decode('OEY0QS05UzJDLTdCMUUtM0Y2QQ==')):
      2880, // 8F4A-9S2C-7B1E-3F6A
  utf8.decode(base64.decode('QzFFNy01QTlGLTJBNEQtMEU4Qw==')):
      2880, // C1E7-5A9F-2A4D-0E8C
  utf8.decode(base64.decode('NkIyRC0zVjhBLUE5QzQtMUU3Qg==')):
      2880, // 6B2D-3V8A-A9C4-1E7B
  utf8.decode(base64.decode('RjBBMy03RzFCLTlENUUtMkI2Rg==')):
      2880, // F0A3-7G1B-9D5E-2B6F
  utf8.decode(base64.decode('QTlEOC00VDJDLTZFMUYtM0MwQQ==')):
      2880, // A9D8-4T2C-6E1F-3C0A
  utf8.decode(base64.decode('M0U3Qi0xQTRBLThGMkQtOUE1Qw==')):
      2880, // 3E7B-1A4A-8F2D-9A5C
  utf8.decode(base64.decode('RDJDNi0wVDlBLTVCM0UtN0ExRA==')):
      2880, // D2C6-0T9A-5B3E-7A1D
  utf8.decode(base64.decode('NUExRi04SDNELTJFN0ItNEQ5QQ==')):
      2880, // 5A1F-8H3D-2E7B-4D9A
  utf8.decode(base64.decode('QjdFNC0yQjlDLTBENkYtMUM4Qg==')):
      2880, // B7E4-2B9C-0D6F-1C8B
  utf8.decode(base64.decode('NEM5Qi03RTJBLTNGMUQtOEIwRQ==')):
      2880, // 4C9B-7E2A-3F1D-8B0E
  // 10 minutes key
  utf8.decode(base64.decode('TTlOUC1DNFRTLTdUSDItVzRFWA==')): 10, // 10 minutes
};

Set<String> get validActivationKeys =>
    _obfuscatedKeys.map((k) => utf8.decode(base64.decode(k))).toSet();

/// Check if a key is a test key
bool isTestKey(String key) {
  return _testKeysExpiration.containsKey(key);
}

/// Get expiration duration in minutes for a test key
/// Returns null if the key is not a test key
int? getTestKeyExpirationMinutes(String key) {
  return _testKeysExpiration[key];
}
