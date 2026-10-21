import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

enum OrderUpdateStatusState {
  initial,
  loading,
  updating,
  loaded,
  error,
}

class OrderUpdateStatusProvider extends ChangeNotifier {
  String message = '';
  int selectedStatus = 0;

  Future<bool> changeOrderSelectedStatus(int index) async {
    if (selectedStatus.toString() != index.toString()) {
      selectedStatus = index;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  OrderUpdateStatusState ordersStatusState = OrderUpdateStatusState.initial;
  late OrderStatuses orderStatuses;
  List<OrderStatusesData> orderStatusesList = [];
  String selectedOrderStatus = "0";

  Future getOrdersStatuses({
    required BuildContext context,
    required String from,
    String isTillCancelable = "0",
  }) async {
    try {
      ordersStatusState = OrderUpdateStatusState.loading;
      notifyListeners();

      Map<String, dynamic> getStatusData =
          (await getOrderStatusesRepository(context: context, isTillCancelable: isTillCancelable));

      if (getStatusData[ApiAndParams.status].toString() == "1") {
        orderStatuses = OrderStatuses.fromJson(getStatusData);
        if (from == "return") {
          orderStatusesList = orderStatuses.returnStatuses ?? [];
          orderStatusesList = (orderStatuses.data ?? []).where((item) => item.id != "8" && item.id !="7").toList();
        } else {
          orderStatusesList = orderStatuses.data ?? [];
          orderStatusesList = (orderStatuses.data ?? []).where((item) => item.id != "8" && item.id != "7").toList();
        }
        ordersStatusState = OrderUpdateStatusState.loaded;
        notifyListeners();
      } else {
        ordersStatusState = OrderUpdateStatusState.loaded;
        showMessage(
            context, getStatusData[ApiAndParams.message], MessageType.warning);
        notifyListeners();
      }
    }catch (e) {
      message = e.toString();
      ordersStatusState = OrderUpdateStatusState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }

  Future updateOrdersStatus({
    required Map<String, String> params,
    required BuildContext context,
    Map<String, File>? filesMap,
  }) async {
    try {
      ordersStatusState = OrderUpdateStatusState.updating;
      notifyListeners();

      Map<String, dynamic> getUpdatedOrderData =
          await updateOrderStatusRepository(params: params, filesMap: filesMap);

      if (getUpdatedOrderData[ApiAndParams.status].toString() == "1") {
        ordersStatusState = OrderUpdateStatusState.loaded;
        showMessage(context, getUpdatedOrderData[ApiAndParams.message], MessageType.success);

        // Auto manage duty and active order for delivery boy
        if (Constant.session.isDeliveryBoy()) {
          final String statusId = params[ApiAndParams.statusId]?.toString() ?? "";
          final String orderId = params[ApiAndParams.orderId]?.toString() ?? "";

          if (statusId == "5") {
            // Out for Delivery: Automatically change to ON DUTY and set active order
            if (!DeliveryBoyTrackingService.instance.isOnDuty) {
              DeliveryBoyTrackingService.instance.startShift();
            }
            if (orderId.isNotEmpty) {
              DeliveryBoyTrackingService.instance.setActiveOrder(orderId);
            }
          } else if (statusId == "6" || statusId == "7" || statusId == "8") {
            // Delivered, Cancelled, or Returned: Clear active order
            if (DeliveryBoyTrackingService.instance.currentOrderId == orderId) {
              DeliveryBoyTrackingService.instance.clearActiveOrder();
            }
          }
        }

        notifyListeners();
        return true;
      } else {
        ordersStatusState = OrderUpdateStatusState.error;
        showMessage(context, getUpdatedOrderData[ApiAndParams.message],
            MessageType.warning);
        notifyListeners();
        return false;
      }
    }catch (e) {
      message = e.toString();
      ordersStatusState = OrderUpdateStatusState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
      return false;
    }
  }

  setSelectedStatus(String index, {BuildContext? context}) {
    selectedOrderStatus = (int.parse(index) + 1).toString();
    if (orderStatusesList.isNotEmpty && int.parse(index) < orderStatusesList.length) {
      selectedOrderStatus = orderStatusesList[int.parse(index)].id.toString();
    } else {
      selectedOrderStatus = (int.parse(index) + 1).toString();
    }

    // If Out for Delivery (status 5) is selected by a delivery boy,
    // automatically transition off-duty to ON DUTY immediately!
    if (Constant.session.isDeliveryBoy() && selectedOrderStatus == "5") {
      if (!DeliveryBoyTrackingService.instance.isOnDuty) {
        debugPrint("[OrderUpdateStatusProvider] Out for delivery status selected. Automatically transitioning to ON DUTY.");
        DeliveryBoyTrackingService.instance.startShift();
        final currentCtx = context ?? Constant.navigatorKay.currentContext;
        if (currentCtx != null) {
          showMessage(currentCtx, "Status: Automatically switched to ON DUTY for delivery", MessageType.success);
        }
      }
    }

    notifyListeners();
  }
}

