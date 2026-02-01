// lib/utils/permission_utils.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests only the storage permission needed for direct writes to Download/.
Future<bool> requestStoragePermission(BuildContext context) async {
  if (!Platform.isAndroid) return true;

  // Android 11+ → all‑files access
  if (await Permission.manageExternalStorage.isGranted ||
      await Permission.manageExternalStorage.request().isGranted) {
    return true;
  }

  // Android 6–10 → WRITE_EXTERNAL_STORAGE
  if (await Permission.storage.isGranted ||
      await Permission.storage.request().isGranted) {
    return true;
  }

  // If permanently denied, send user to settings
  if (await Permission.manageExternalStorage.isPermanentlyDenied ||
      await Permission.storage.isPermanentlyDenied) {
    openAppSettings();
  }
  return false;
}
