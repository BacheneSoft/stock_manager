import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/services/logger_service.dart';
import 'core/config/app_config.dart';

void main() async {
  // Catch Flutter framework errors (synchronous)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    LoggerService.e('Flutter Error: ${details.exception}', details.exception, details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Catch asynchronous errors outside of Flutter (Platform/Isolate errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.e('Asynchronous/Platform Error', error, stack);
    return true; // Error was handled
  };
  
  final prefs = await SharedPreferences.getInstance();
  
  bool isActivated = (prefs.getBool('isActivated') ?? false);
  
  if (AppConfig.isDemoMode) {
    // Demo Mode Trial Logic
    final firstLaunch = prefs.getInt('demo_first_launch');
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (firstLaunch == null) {
      // First time running demo mode, store the timestamp
      await prefs.setInt('demo_first_launch', now);
      isActivated = true;
    } else {
      // Check if trial has expired
      final diffDays = (now - firstLaunch) / (1000 * 60 * 60 * 24);
      if (diffDays <= AppConfig.demoTrialDays) {
        isActivated = true;
      } else {
        // Trial expired, fallback to real activation check (unless already activated)
        LoggerService.w('Demo Mode trial expired (${AppConfig.demoTrialDays} days).');
      }
    }
  }

  // Check if activation has expired (for test keys)
  if (isActivated) {
    final activationType = prefs.getString('activation_type');
    if (activationType == 'test') {
      final activationTimestamp = prefs.getInt('activation_timestamp');
      final expirationMinutes = prefs.getInt('test_expiration_minutes');

      if (activationTimestamp != null && expirationMinutes != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedMinutes = (now - activationTimestamp) ~/ (1000 * 60);

        if (elapsedMinutes >= expirationMinutes) {
          // Activation expired, clear activation data
          await prefs.setBool('isActivated', false);
          await prefs.remove('activation_type');
          await prefs.remove('activation_timestamp');
          await prefs.remove('test_expiration_minutes');
          isActivated = false;
        }
      }
    }
  }

  runApp(StockManagerApp(isActivated: isActivated));
}

// Note: PinLockWrapper and ActivationScreen are still here for now, 
// they will be moved to screens folder in the next step.
// Classes below this line are unchanged but will be relocated shortly.

