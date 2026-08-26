import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics Service for Google Analytics tracking
/// Centralized service to manage all analytics events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  /// Initialize Firebase Analytics
  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Enable analytics collection
      await _analytics!.setAnalyticsCollectionEnabled(true);

      print('✅ Firebase Analytics initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase Analytics: $e');
    }
  }

  /// Get the FirebaseAnalytics instance
  static FirebaseAnalytics? get analytics => _analytics;

  /// Get the FirebaseAnalyticsObserver for navigation tracking
  static FirebaseAnalyticsObserver? get observer => _observer;

  // ==================== USER PROPERTIES ====================

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userType,
    String? sellerStatus,
    String? city,
  }) async {
    try {
      if (userType != null) {
        await _analytics?.setUserProperty(name: 'user_type', value: userType);
      }
      if (sellerStatus != null) {
        await _analytics?.setUserProperty(name: 'seller_status', value: sellerStatus);
      }
      if (city != null) {
        await _analytics?.setUserProperty(name: 'city', value: city);
      }
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  // ==================== SCREEN TRACKING ====================

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  // ==================== AUTHENTICATION EVENTS ====================

  /// Log login event
  static Future<void> logLogin({String? method}) async {
    try {
      await _analytics?.logLogin(loginMethod: method ?? 'email');
    } catch (e) {
      print('Error logging login: $e');
    }
  }

  /// Log signup event
  static Future<void> logSignUp({String? method}) async {
    try {
      await _analytics?.logSignUp(signUpMethod: method ?? 'email');
    } catch (e) {
      print('Error logging signup: $e');
    }
  }

  /// Log logout event
  static Future<void> logLogout() async {
    try {
      await _analytics?.logEvent(name: 'logout');
    } catch (e) {
      print('Error logging logout: $e');
    }
  }

  // ==================== PRODUCT EVENTS ====================

  /// Log product view
  static Future<void> logProductView({
    required String productId,
    required String productName,
    String? category,
    double? price,
  }) async {
    try {
      await _analytics?.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: productName,
            itemCategory: category,
            price: price,
          ),
        ],
      );
    } catch (e) {
      print('Error logging product view: $e');
    }
  }

  /// Log product added
  static Future<void> logProductAdded({
    required String productId,
    required String productName,
    String? category,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'product_added',
        parameters: {
          'product_id': productId,
          'product_name': productName,
          if (category != null) 'category': category,
        },
      );
    } catch (e) {
      print('Error logging product added: $e');
    }
  }

  /// Log product updated
  static Future<void> logProductUpdated({
    required String productId,
    required String productName,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'product_updated',
        parameters: {
          'product_id': productId,
          'product_name': productName,
        },
      );
    } catch (e) {
      print('Error logging product updated: $e');
    }
  }

  /// Log product deleted
  static Future<void> logProductDeleted({
    required String productId,
    required String productName,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'product_deleted',
        parameters: {
          'product_id': productId,
          'product_name': productName,
        },
      );
    } catch (e) {
      print('Error logging product deleted: $e');
    }
  }

  // ==================== ORDER EVENTS ====================

  /// Log order view
  static Future<void> logOrderView({
    required String orderId,
    double? value,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'order_viewed',
        parameters: {
          'order_id': orderId,
          if (value != null) 'value': value,
        },
      );
    } catch (e) {
      print('Error logging order view: $e');
    }
  }

  /// Log order status updated
  static Future<void> logOrderStatusUpdated({
    required String orderId,
    required String status,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'order_status_updated',
        parameters: {
          'order_id': orderId,
          'new_status': status,
        },
      );
    } catch (e) {
      print('Error logging order status update: $e');
    }
  }

  // ==================== STOCK MANAGEMENT EVENTS ====================

  /// Log stock updated
  static Future<void> logStockUpdated({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'stock_updated',
        parameters: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
    } catch (e) {
      print('Error logging stock update: $e');
    }
  }

  // ==================== WALLET EVENTS ====================

  /// Log withdrawal request
  static Future<void> logWithdrawalRequest({
    required double amount,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'withdrawal_requested',
        parameters: {
          'amount': amount,
        },
      );
    } catch (e) {
      print('Error logging withdrawal request: $e');
    }
  }

  // ==================== SEARCH EVENTS ====================

  /// Log search
  static Future<void> logSearch({
    required String searchTerm,
    String? category,
  }) async {
    try {
      await _analytics?.logSearch(
        searchTerm: searchTerm,
        parameters: {
          if (category != null) 'search_category': category,
        },
      );
    } catch (e) {
      print('Error logging search: $e');
    }
  }

  // ==================== FILTER EVENTS ====================

  /// Log filter applied
  static Future<void> logFilterApplied({
    required String filterType,
    required String filterValue,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'filter_applied',
        parameters: {
          'filter_type': filterType,
          'filter_value': filterValue,
        },
      );
    } catch (e) {
      print('Error logging filter: $e');
    }
  }

  // ==================== ERROR TRACKING ====================

  /// Log error
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (screenName != null) 'screen_name': screenName,
        },
      );
    } catch (e) {
      print('Error logging error: $e');
    }
  }

  // ==================== CUSTOM EVENTS ====================

  /// Log custom event
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Error logging custom event: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Reset analytics data (for testing)
  static Future<void> resetAnalyticsData() async {
    try {
      await _analytics?.resetAnalyticsData();
    } catch (e) {
      print('Error resetting analytics data: $e');
    }
  }

  /// Enable/Disable analytics collection
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics?.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      print('Error setting analytics collection: $e');
    }
  }
}
