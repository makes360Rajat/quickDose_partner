import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getOrdersRepository(
    {required Map<String, String> params,
    required BuildContext context}) async {
  try {
    final result = await sendApiRequest(
        apiName: ApiAndParams.apiOrdersHistory, params: params, isPost: false);

    return Map.from(
      jsonDecode(result),
    );
  } catch (e) {
    //
    return {};
  }
}Future<Map<String, dynamic>> getPickupOrdersRepository(
    {required Map<String, String> params,
    required BuildContext context}) async {
  try {
    final result = await sendApiRequest(
        apiName: ApiAndParams.apiSelfPickupOrders, params: params, isPost: false);

    return Map.from(
      jsonDecode(result),
    );
  } catch (e) {
    //
    return {};
  }
}

Future<Map<String, dynamic>> getOrderStatusesRepository(
    {required BuildContext context, String? isTillCancelable, String? returnRequestId}) async {
  try {
    Map<String, dynamic> params = {};

    if (isTillCancelable != null && isTillCancelable.isNotEmpty) {
      params[ApiAndParams.isTillCancelable] = isTillCancelable;
    }

    if (returnRequestId != null && returnRequestId.isNotEmpty) {
      params[ApiAndParams.returnRequestId] = returnRequestId;
    }
    final result = await sendApiRequest(
        apiName: ApiAndParams.apiOrderStatuses, params: /* (isTillCancelable != null && isTillCancelable.isNotEmpty) ? {ApiAndParams.isTillCancelable: isTillCancelable} : */ params, isPost: false);

    return Map.from(
      jsonDecode(result),
    );
  } catch (e) {
    //
    return {};
  }
}


Future<Map<String, dynamic>> getPickupOrderStatusesRepository({required BuildContext context}) async {
  try {
    final result = await sendApiRequest(apiName: ApiAndParams.apiSelfPickupOrderStatuses, params: {}, isPost: false);

    return Map.from(
      jsonDecode(result),
    );
  } catch (e) {
    //
    return {};
  }
}

Future<Map<String, dynamic>> updateOrderStatusRepository(
    {required Map<String, String> params}) async {
  try {
    final response = await sendApiRequest(
        apiName: ApiAndParams.apiUpdateOrderStatus,
        params: params,
        isPost: true);

    if (response == null) {
      throw Exception("Something went wrong");
    }

    return json.decode(response);
  } catch (e) {
    throw e;
  }
}

Future<Map<String, dynamic>> updateReturnOrderStatusRepository({required Map<String, String> params}) async {
  try {
    final response = await sendApiRequest(apiName: ApiAndParams.returnRequestStatusUpdateApi, params: params, isPost: true);

    if (response == null) {
      throw Exception("Something went wrong");
    }

    return json.decode(response);
  } catch (e) {
    throw e;
  }
}

Future<Map<String, dynamic>> updatePickupOrderStatusRepository({required Map<String, String> params}) async {
  try {
    final response = await sendApiRequest(apiName: ApiAndParams.apiUpdateSelfPickupStatus, params: params, isPost: true);

    if (response == null) {
      throw Exception("Something went wrong");
    }

    return json.decode(response);
  } catch (e) {
    throw e;
  }
}

Future<Map<String, dynamic>> updateOrdersDeliveryBoyRepository(
    {required Map<String, String> params}) async {
  try {
    final response = await sendApiRequest(
        apiName: ApiAndParams.apiUpdateOrderDeliveryBoy,
        params: params,
        isPost: true);

    if (response == null) {
      throw Exception("Something went wrong");
    }

    return json.decode(response);
  } catch (e) {
    throw e;
  }
}

Future<Map<String, dynamic>> getSellerOrderReturnRequestsRepository({
  required Map<String, String> params,
  required BuildContext context,
}) async {
  try {
    final result = await sendApiRequest(
      apiName: ApiAndParams.returnRequests,
      params: params,
      isPost: false,
    );

    return json.decode(result);
  } catch (e) {
    return {};
  }
}

Future<Map<String, dynamic>> getDeliveryBoyOrderReturnRequestsRepository({
  required Map<String, String> params,
  required BuildContext context,
}) async {
  try {
    final result = await sendApiRequest(
      apiName: ApiAndParams.returnRequests,
      params: params,
      isPost: false,
    );

    return json.decode(result);
  } catch (e) {
    return {};
  }
}

Future<Map<String, dynamic>> getReturnOrderByIdRepository({
  required String returnRequestId,
}) async {
  try {
    final result = await sendApiRequest(
      apiName: ApiAndParams.apiReturnRequestById,
      params: {ApiAndParams.returnRequestId: returnRequestId},
      isPost: false,
    );

    return json.decode(result);
  } catch (e) {
    debugPrint("Error in getReturnRequestByIdRepository: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> cancelOrderItemRepository({required Map<String, String> params}) async {
  try {
    final response = await sendApiRequest(
      apiName: ApiAndParams.cancelOrderItem,
      params: params,
      isPost: true,
    );

    if (response == null) {
      throw Exception("Something went wrong");
    }

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getLiveOrderByIdRepository({
  required String orderId,
}) async {
  try {
    final result = await sendApiRequest(
      apiName: ApiAndParams.apiLiveOrderById,
      params: {ApiAndParams.orderId: orderId},
      isPost: false,
    );

    return json.decode(result);
  } catch (e) {
    debugPrint("Error in getLiveOrderByIdRepository: ${e.toString()}");
    rethrow;
  }
}
