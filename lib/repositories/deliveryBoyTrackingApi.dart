import 'package:flutter/foundation.dart';
import 'package:project/helper/utils/generalImports.dart';

/// Calls the Admin-integrated Delivery Boy location push endpoint
Future<Map<String, dynamic>> pushDeliveryBoyLocationApi({
  required Map<String, dynamic> params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiDeliveryBoyLocationPush,
      params: params,
      isPost: true,
    );

    if (response != null && response is String) {
      return json.decode(response) as Map<String, dynamic>;
    } else if (response is Map<String, dynamic>) {
      return response;
    }
  } catch (e) {
    debugPrint("Primary location push error: $e, trying public fallback...");
    try {
      var fallbackResponse = await sendApiRequest(
        apiName: ApiAndParams.apiDeliveryBoyPublicLocationPush,
        params: params,
        isPost: true,
      );
      if (fallbackResponse != null && fallbackResponse is String) {
        return json.decode(fallbackResponse) as Map<String, dynamic>;
      }
    } catch (fallbackError) {
      debugPrint("Public location push error: $fallbackError");
    }
  }
  return <String, dynamic>{};
}

/// Toggles Delivery Boy shift online / offline for admin tracking
Future<Map<String, dynamic>> toggleDeliveryBoyShiftApi({
  required Map<String, dynamic> params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiDeliveryBoyShiftToggle,
      params: params,
      isPost: true,
    );

    if (response != null && response is String) {
      return json.decode(response) as Map<String, dynamic>;
    } else if (response is Map<String, dynamic>) {
      return response;
    }
  } catch (e) {
    debugPrint("Primary shift toggle error: $e, trying public fallback...");
    try {
      var fallbackResponse = await sendApiRequest(
        apiName: ApiAndParams.apiDeliveryBoyPublicShiftToggle,
        params: params,
        isPost: true,
      );
      if (fallbackResponse != null && fallbackResponse is String) {
        return json.decode(fallbackResponse) as Map<String, dynamic>;
      }
    } catch (fallbackError) {
      debugPrint("Public shift toggle error: $fallbackError");
    }
  }
  return <String, dynamic>{};
}

/// Retrieves shift stats (today km, orders, shift duration)
Future<Map<String, dynamic>> getDeliveryBoyShiftStatsApi({
  Map<String, dynamic>? params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiDeliveryBoyShiftStats,
      params: params ?? {},
      isPost: false,
    );

    if (response != null && response is String) {
      return json.decode(response) as Map<String, dynamic>;
    } else if (response is Map<String, dynamic>) {
      return response;
    }
  } catch (e) {
    debugPrint("Error fetching shift stats: $e");
  }
  return <String, dynamic>{};
}
