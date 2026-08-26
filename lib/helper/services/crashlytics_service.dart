import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize Crashlytics service
  static Future<void> initialize() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection
      await _crashlytics?.setCrashlyticsCollectionEnabled(true);

      if (kDebugMode) {
        // In debug mode, you can choose to disable Crashlytics
        // await _crashlytics?.setCrashlyticsCollectionEnabled(false);
        print('Firebase Crashlytics initialized (Debug Mode)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Crashlytics: $e');
      }
    }
  }

  /// Log a custom error to Crashlytics
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics?.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error recording to Crashlytics: $e');
      }
    }
  }

  /// Log a custom message to Crashlytics
  static Future<void> log(String message) async {
    try {
      await _crashlytics?.log(message);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging to Crashlytics: $e');
      }
    }
  }

  /// Set user identifier for crash reports
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user ID in Crashlytics: $e');
      }
    }
  }

  /// Set custom key-value pairs for crash reports
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics?.setCustomKey(key, value);
      } else {
        await _crashlytics?.setCustomKey(key, value.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting custom key in Crashlytics: $e');
      }
    }
  }

  /// Force a crash (for testing purposes only)
  static void forceCrash() {
    if (kDebugMode) {
      print('Force crash called - only works in release mode');
    }
    throw Exception('Test crash from Crashlytics');
  }

  /// Check if Crashlytics is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      final enabled = await _crashlytics?.isCrashlyticsCollectionEnabled;
      return enabled ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Crashlytics status: $e');
      }
      return false;
    }
  }
}
