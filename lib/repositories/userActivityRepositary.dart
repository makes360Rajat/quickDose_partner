import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future updateUserApiRepository({
  required Map<String, dynamic> params,
  required String from,
  required Map<String, File> filesMap,
}) async {
  try {
    var apiName = from.isEmpty
        ? "${Constant.hostUrl}api/${Constant.session.isSeller() ? "sellers" : "delivery_boys"}/${ApiAndParams.apiUpdateUser}"
        : ApiAndParams.apiRegisterUser;

    if (filesMap.isEmpty) {
      return jsonDecode(await sendApiRequest(
        apiName: apiName,
        params: params,
        isPost: true,
      ));
    } else {
      return await sendApiMultiPartRequest(
        apiName: apiName,
        params: params,
        filesMap: filesMap,
      );
    }
  } catch (e) {
    debugPrint(">>>>> ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getLoginRepository({required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiLogin,
      params: params,
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getLoginRepository: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getProfileApi({required BuildContext context, required String id}) async {
  try {
    var response = await sendApiRequest(
      apiName: "${Constant.hostUrl}api/${Constant.session.isSeller() ? "sellers" : "delivery_boys"}/${ApiAndParams.apiEditProfile}/$id",
      params: {},
      isPost: false,
    );

    return await json.decode(response);
  } catch (e) {
    debugPrint("Error in getProfileApi: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> deleteUserAccount({required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: Constant.session.isSeller() ? ApiAndParams.apiSellerDeleteAccount : ApiAndParams.apiDeliveryBoyDeleteAccount,
      params: params,
      isPost: false,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in deleteUserAccount: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> updateSellerStatus({required BuildContext context, required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiUpdateSellerStatus,
      params: params,
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in updateSellerStatus: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getSellerStatus({required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiGetSellerStatus,
      params: {},
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getSellerStatus: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getDeliveryBoyStatus({required BuildContext context}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiGetDeliveryBoyStatus,
      params: {},
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getDeliveryBoyStatus: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> forgotPasswordApi({required BuildContext context, required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiForgotPassword,
      params: params,
      isPost: true,
    );

    if (response == null) {
      return {
        ApiAndParams.status: "0",
        ApiAndParams.message: "something_went_wrong",
      };
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in forgotPasswordApi: ${e.toString()}");
    rethrow;
  }
}

Future<void> logoutApiRepository({required String fcmToken}) async {
  try {
    await sendApiRequest(
      apiName: ApiAndParams.apiLogout,
      params: {ApiAndParams.fcmToken: fcmToken},
      isPost: true,
    );
  } catch (e) {
    debugPrint("Error in logoutApiRepository: ${e.toString()}");
  }
}

Future<Map<String, dynamic>> addFcmTokenApi({required String fcmToken}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiAddFcmToken,
      params: {ApiAndParams.fcmToken: fcmToken},
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in addFcmTokenApi: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> updateFcmTokenApi({required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiUpdateFcmToken,
      params: params,
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in updateFcmTokenApi: ${e.toString()}");
    rethrow;
  }
}
