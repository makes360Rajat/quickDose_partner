import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/helper/utils/apiAndParams.dart';
import 'package:project/helper/utils/constant.dart';
import 'package:project/helper/sessionManager.dart';
import 'package:project/repositories/deliveryBoyTrackingApi.dart';

class DeliveryBoyTrackingService extends ChangeNotifier {
  static final DeliveryBoyTrackingService instance = DeliveryBoyTrackingService._internal();

  DeliveryBoyTrackingService._internal();

  Timer? _trackingTimer;
  bool _isOnDuty = false;
  final ValueNotifier<bool> isOnDutyNotifier = ValueNotifier<bool>(false);
  bool _isPinging = false;
  String _deviceId = '';
  String _deviceModel = '';
  String? _currentOrderId;
  double _todayDistanceKm = 0.0;
  double _currentSpeed = 0.0;
  DateTime? _lastPingTime;
  Position? _lastPosition;

  bool get isOnDuty => _isOnDuty;
  bool get isPinging => _isPinging;
  String get deviceId => _deviceId;
  String get deviceModel => _deviceModel;
  String? get currentOrderId => _currentOrderId;
  double get todayDistanceKm => _todayDistanceKm;
  double get currentSpeed => _currentSpeed;
  DateTime? get lastPingTime => _lastPingTime;
  Position? get lastPosition => _lastPosition;

  /// Initialize device info and restore duty status
  Future<void> init() async {
    await _initDeviceInfo();

    if (Constant.session.isDeliveryBoy()) {
      // Check if rider was on duty previously, default to true for automatic admin tracking
      final savedDuty = Constant.session.getBoolData(SessionManager.keyIsOnDuty);
      if (savedDuty) {
        startShift(silent: true);
      } else {
        // Automatically start duty so admin can track rider as soon as app is opened
        startShift(silent: true);
      }
    }
  }

  Future<void> _initDeviceInfo() async {
    if (_deviceId.isNotEmpty) return;

    // Check cached device ID
    String cachedId = Constant.session.getData(SessionManager.keyDeviceId);
    if (cachedId.isNotEmpty) {
      _deviceId = cachedId;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        if (_deviceId.isEmpty) {
          _deviceId = 'AND-${androidInfo.id.substring(0, androidInfo.id.length > 12 ? 12 : androidInfo.id.length)}';
        }
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}'.trim();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        if (_deviceId.isEmpty) {
          _deviceId = 'IOS-${iosInfo.identifierForVendor?.substring(0, 12) ?? "DEVICE"}';
        }
        _deviceModel = '${iosInfo.name} ${iosInfo.utsname.machine}'.trim();
      } else {
        if (_deviceId.isEmpty) {
          _deviceId = 'DEV-${DateTime.now().millisecondsSinceEpoch}';
        }
        _deviceModel = 'Mobile';
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      if (_deviceId.isEmpty) {
        _deviceId = 'RIDER-${Constant.session.getData(SessionManager.userId)}';
      }
      _deviceModel = 'Android/iOS';
    }

    Constant.session.setData(SessionManager.keyDeviceId, _deviceId, false);
    debugPrint('[DeliveryBoyTracker] Device initialized: ID=$_deviceId, Model=$_deviceModel');
  }

  /// Start Shift / Go On Duty (notifies Admin live map)
  Future<bool> startShift({bool silent = false}) async {
    await _initDeviceInfo();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          debugPrint('[DeliveryBoyTracker] Location permission denied.');
          return false;
        }
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        _lastPosition = position;
      } catch (e) {
        debugPrint('[DeliveryBoyTracker] Initial position fetch timeout/error: $e');
      }

      final Map<String, dynamic> params = {
        'status': 'online',
        ApiAndParams.deviceId: _deviceId,
        ApiAndParams.deviceModel: _deviceModel,
        ApiAndParams.appVersion: '1.0.0',
        if (position != null) ApiAndParams.latitude: position.latitude.toString(),
        if (position != null) ApiAndParams.longitude: position.longitude.toString(),
        'delivery_boy_id': Constant.session.getData(SessionManager.userId),
      };

      final res = await toggleDeliveryBoyShiftApi(params: params);
      debugPrint('[DeliveryBoyTracker] Shift started response: $res');

      _isOnDuty = true;
      isOnDutyNotifier.value = true;
      Constant.session.setBoolData(SessionManager.keyIsOnDuty, true, false);

      // Start periodic continuous background/foreground location stream (every 15s)
      _startTrackingTimer();

      // Trigger immediate ping
      if (position != null) {
        pushLocationPing(position: position);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[DeliveryBoyTracker] Error starting shift: $e');
      return false;
    }
  }

  /// End Shift / Go Off Duty (notifies Admin live map)
  Future<bool> endShift() async {
    _stopTrackingTimer();

    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    final Map<String, dynamic> params = {
      'status': 'offline',
      ApiAndParams.deviceId: _deviceId,
      if (position != null) ApiAndParams.latitude: position.latitude.toString(),
      if (position != null) ApiAndParams.longitude: position.longitude.toString(),
      'delivery_boy_id': Constant.session.getData(SessionManager.userId),
    };

    await toggleDeliveryBoyShiftApi(params: params);
    debugPrint('[DeliveryBoyTracker] Shift ended.');

    _isOnDuty = false;
    isOnDutyNotifier.value = false;
    _currentOrderId = null;
    Constant.session.setBoolData(SessionManager.keyIsOnDuty, false, false);
    notifyListeners();
    return true;
  }

  void _startTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isOnDuty && Constant.session.isDeliveryBoy()) {
        pushLocationPing();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  /// Push single road coordinate breadcrumb ping to Admin backend
  Future<void> pushLocationPing({
    Position? position,
    String? activeOrderId,
    String? activityType,
  }) async {
    if (_isPinging) return;
    _isPinging = true;

    try {
      Position? currentPos = position;
      if (currentPos == null) {
        currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      }

      _lastPosition = currentPos;
      _lastPingTime = DateTime.now();

      // Convert m/s to km/h
      final speedKmh = (currentPos.speed * 3.6).clamp(0.0, 150.0);
      _currentSpeed = double.parse(speedKmh.toStringAsFixed(1));

      final targetOrderId = activeOrderId ?? _currentOrderId;
      final targetActivity = activityType ?? (targetOrderId != null ? 'delivering' : 'returning_or_idle');

      final Map<String, dynamic> params = {
        ApiAndParams.latitude: currentPos.latitude.toString(),
        ApiAndParams.longitude: currentPos.longitude.toString(),
        ApiAndParams.speed: _currentSpeed.toString(),
        ApiAndParams.heading: currentPos.heading.toStringAsFixed(1),
        ApiAndParams.accuracy: currentPos.accuracy.toStringAsFixed(1),
        ApiAndParams.deviceId: _deviceId,
        'delivery_boy_id': Constant.session.getData(SessionManager.userId),
        if (targetOrderId != null && targetOrderId.isNotEmpty) ApiAndParams.orderId: targetOrderId,
        ApiAndParams.activityType: targetActivity,
      };

      final result = await pushDeliveryBoyLocationApi(params: params);
      if (result.isNotEmpty && result['data'] != null) {
        final data = result['data'];
        if (data['total_distance_km'] != null) {
          _todayDistanceKm = (data['total_distance_km'] as num).toDouble();
        }
      }

      debugPrint('[DeliveryBoyTracker] 📍 Ping sent to Admin: ${currentPos.latitude}, ${currentPos.longitude} | Speed: $_currentSpeed km/h | Order: $targetOrderId');
    } catch (e) {
      debugPrint('[DeliveryBoyTracker] Ping error: $e');
    } finally {
      _isPinging = false;
      notifyListeners();
    }
  }

  /// Bind an active order being delivered
  void setActiveOrder(String orderId) {
    _currentOrderId = orderId;
    debugPrint('[DeliveryBoyTracker] Active delivering order set: $orderId');
    pushLocationPing(activeOrderId: orderId, activityType: 'delivering');
    notifyListeners();
  }

  /// Unbind active order when delivered or completed
  void clearActiveOrder() {
    _currentOrderId = null;
    debugPrint('[DeliveryBoyTracker] Active order cleared.');
    pushLocationPing(activityType: 'returning_or_idle');
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTrackingTimer();
    super.dispose();
  }
}
