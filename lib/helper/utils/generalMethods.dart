import 'dart:core';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio_curl_interceptor/dio_curl_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/helper/generalWidgets/messageContainer.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:dio/dio.dart' as dio;

enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {MessageType.success: ColorsRes.appColorGreen, MessageType.error: ColorsRes.appColorRed, MessageType.warning: ColorsRes.appColorOrange};

Map<MessageType, Widget> messageIcon = {
  MessageType.success: defaultImg(image: AppAssets.doneIcon, iconColor: ColorsRes.appColorGreen),
  MessageType.error: defaultImg(image: AppAssets.errorIcon, iconColor: ColorsRes.appColorRed),
  MessageType.warning: defaultImg(image: AppAssets.warningIcon, iconColor: ColorsRes.appColorOrange),
};

Future<bool> checkInternet() async {
  bool check = false;

  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult[0] == ConnectivityResult.mobile ||
      connectivityResult[0] == ConnectivityResult.wifi ||
      connectivityResult[0] == ConnectivityResult.ethernet) {
    check = true;
  }
  return check;
}

NetworkStatus getNetworkStatus(ConnectivityResult status) {
  return status == ConnectivityResult.mobile || status == ConnectivityResult.wifi || status == ConnectivityResult.ethernet
      ? NetworkStatus.Online
      : NetworkStatus.Offline;
}

showMessage(
  BuildContext context,
  String msg,
  MessageType type,
) async {
  FocusScope.of(context).unfocus(); // Unfocused any focused text field
  SystemChannels.textInput.invokeMethod('TextInput.hide'); // Close the keyboard

  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: msg,
          type: type,
        ),
      );
    },
  );
  overlayState.insert(overlayEntry);
  await Future.delayed(
    Duration(
      milliseconds: Constant.messageDisplayDuration,
    ),
  );

  overlayEntry.remove();
}

Locale getLocaleFromLangCode(String languageCode) {
  List<String> result = languageCode.split("-");
  return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
}

String setFirstLetterUppercase(String value) {
  if (value.isNotEmpty) value = value.replaceAll("_", ' ');
  return value.toTitleCase();
}

Future sendApiRequest({required String apiName, required Map<String, dynamic> params, required bool isPost, bool? isRequestedForInvoice, bool? privacyAndTerms=false}) async {
  try {
    String token = Constant.session.getData(SessionManager.keyAccessToken);
    String baseUrl = Constant.session.isUserLoggedIn()?
    "${Constant.hostUrl}api/${Constant.session.isSeller() ? "seller" : "delivery_boy"}/": 
    "${privacyAndTerms!?Constant.hostUrl : "${Constant.hostUrl}api/"}";//${Constant.session.isSeller() ? "seller" : "delivery_boy"}/

    String languageCode = Constant.session.getData(SessionManager.keySelectedLanguageCode);

    Map<String, String> headersData = {
      "accept": "application/json",
    };

    if (token.trim().isNotEmpty) {
      headersData["Authorization"] = "Bearer $token";
    }

    headersData["x-access-key"] = "903361";

    if (languageCode.trim().isNotEmpty) {
      headersData["Content-Language"] = languageCode;
    }

    String mainUrl = apiName.contains("http") ? apiName : "${baseUrl}$apiName";

    http.Response response;
    if (isPost) {
    if(privacyAndTerms == true){
      response = await http.post(Uri.parse("${Constant.hostUrl}api/$apiName"), body: params.isNotEmpty ? params : null, headers: headersData);
    }
    else{
      response = await http.post(Uri.parse(mainUrl), body: params.isNotEmpty ? params : null, headers: headersData);
    }
    } else {
      mainUrl = await Constant.getGetMethodUrlWithParams(apiName.contains("http") ? apiName : "${baseUrl}$apiName", params);

      response = await http.get(Uri.parse(mainUrl), headers: headersData);
    }

    if (response.statusCode == 200) {
      if (response.body == "null") {
        return null;
      }
      if (kDebugMode) {
        print("API IS : $mainUrl, PARAMS : $params, CODE : ${response.statusCode}, ${response.body},");
      }
      return isRequestedForInvoice == true ? response.bodyBytes : response.body;
    } else {
      if(response.statusCode == 401){
        Constant.session.processToLogout(Constant.navigatorKay.currentContext!);
      }
      if (kDebugMode) {
        print("ERROR IS API : $mainUrl, PARAMS : $params, CODE : ${response.statusCode}, ${response.body},");
      }
      return null;
    }
  } on SocketException {
    await Future.delayed(const Duration(milliseconds: 1800));
    throw SocketException('No Internet Connection');
  } catch (e) {
    return e.toString();
  }
}

// Future sendApiMultiPartRequest(
//     {required String apiName,
//     required Map<String, String> params,
//     required List<String>? fileParamsNames,
//     required List<String> fileParamsFilesPath,
//     File? mainImage,
//     List<File>? otherImage}) async {
//   try {
//     dio.Dio dioClient = dio.Dio();
//     String token = Constant.session.getData(SessionManager.keyAccessToken);
//     String baseUrl = "${Constant.hostUrl}api/${Constant.session.isSeller() ? "seller" : "delivery_boy"}/";
//     String mainUrl = apiName.contains("http") ? apiName : "$baseUrl$apiName";
//
//     // Headers
//     dioClient.options.headers = {
//       "Authorization": "Bearer $token",
//       "x-access-key": "903361",
//     };
//
//     // Form Data
//     dio.FormData formData = dio.FormData.fromMap(params);
//
//    // Add multiple image files with dynamic fileParamsNames[i]
//     if (fileParamsNames!.isNotEmpty && otherImage != null && fileParamsNames.isNotEmpty) {
//       for (int i = 0; i < otherImage.length; i++) {
//         File image = otherImage[i];
//
//         final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
//         var extension = mimeType.split("/");
//
//         formData.files.add(
//           MapEntry(
//             fileParamsNames[i], // Use fileParamsNames[i] as the dynamic key for each image
//             await dio.MultipartFile.fromFile(
//               image.path,
//               filename: image.path.split('/').last,
//               contentType: MediaType(extension[0], extension[1]),
//             ),
//           ),
//         );
//       }
//     }
//
//
//     // Add single image file
//     if (mainImage != null) {
//       final mimeType = lookupMimeType(mainImage.path) ?? 'application/octet-stream';
//       var extension = mimeType.split("/");
//
//       formData.files.add(
//         MapEntry(
//           "image",
//           await dio.MultipartFile.fromFile(
//             mainImage.path,
//             filename: mainImage.path.split('/').last,
//             contentType: MediaType(extension[0], extension[1]),
//           ),
//         ),
//       );
//     }
//
//     // Send Request
//     dio.Response response = await dioClient.post(
//       mainUrl,
//       data: formData,
//       options: dio.Options(
//         contentType: 'multipart/form-data',
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       return response.data;
//     } else {
//       if (kDebugMode) {
//         print("ERROR IS : ${response.data}, API : $baseUrl, PARAMS : $params, CODE : ${response.statusCode}");
//       }
//       return null;
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print("ERROR IS CACHE : ${e.toString()}");
//     }
//     rethrow;
//   }
// }

Future sendApiMultiPartRequest({required String apiName, required Map<String, dynamic> params, required Map<String, File> filesMap}) async {
  try {
    dio.Dio dioClient = dio.Dio();
    dioClient.interceptors.add(CurlInterceptor());
    String token = Constant.session.getData(SessionManager.keyAccessToken);
    String baseUrl = "${Constant.hostUrl}api/${Constant.session.isSeller() ? "seller" : "delivery_boy"}/";
    String mainUrl = apiName.contains("http") ? apiName : "$baseUrl$apiName";

    String languageCode = Constant.session.getData(SessionManager.keySelectedLanguageCode);

    // Headers
    dioClient.options.headers = {
      "Authorization": "Bearer $token",
      "x-access-key": "903361",
      if (languageCode.trim().isNotEmpty) "Content-Language": languageCode,
    };

    // Form Data
    dio.FormData formData = dio.FormData.fromMap(params);

    // Add multiple image files with dynamic fileParamsNames[i]
    if (filesMap.isNotEmpty) {
      // Extract keys
      List<String> keys = filesMap.keys.toList();

      // Extract files
      List<File> file = filesMap.values.toList();
      for (int i = 0; i < file.length; i++) {
        final mimeType = lookupMimeType(file[i].path) ?? 'application/octet-stream';
        var extension = mimeType.split("/");

        formData.files.add(
          MapEntry(
            keys[i],
            // Use fileParamsNames[i] as the dynamic key for each image
            await dio.MultipartFile.fromFile(
              file[i].path,
              filename: file[i].path.split('/').last,
              contentType: MediaType(extension[0], extension[1]),
            ),
          ),
        );
      }
    }

    // Send Request
    dio.Response response = await dioClient.post(
      mainUrl,
      data: formData,
      options: dio.Options(
        contentType: 'multipart/form-data',
      ),
    );
    if (kDebugMode) {
      print("ERROR IS : ${response.data}, API : $mainUrl, PARAMS : $params, CODE : ${response.statusCode}");
    }

    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  } on dio.DioException catch (e) {
    debugPrint("Server error ${e.response?.statusCode}");
    debugPrint("Message: ${e.response?.data}");
  } on SocketException {
    await Future.delayed(const Duration(milliseconds: 1800));
    throw SocketException('No Internet Connection');
  } catch (e) {
    if (kDebugMode) {
      print("ERROR IS CACHE : ${e.toString()}");
    }
    rethrow;
  }
}

String? validateEmail(String value) {
  /* String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$"; */
      String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regex = RegExp(pattern);
  if (value.isEmpty || !regex.hasMatch(value))
    return 'Enter a valid email address';
  else
    return null;
}

emailValidation(String val, String msg) {
  return validateEmail(
    val.trim(),
  );
}

percentageValidation(String val, String msg) {
  if (val.isNotEmpty) {
    double percentage = val.toDouble!;
    if (percentage > 100 || percentage < 0) {
      return "Commission should be greater then 0% and less then 100%!";
    } else {
      return null;
    }
  } else {
    return "Commission should not be empty!";
  }
}

emptyValidation(String val, String msg) {
  if (val.trim().isEmpty) {
    return msg;
  }
  return null;
}

optionalFieldValidation(String val, String msg) {
  return null;
}

/* passwordValidation(String val, String msg) {
  if (val == "false") {
    return "";
  }
  return null;
} */
String? passwordValidation(String? value, String errorMessage) {
  if (value == null || value.trim().isEmpty) {
    return enterPasswordLabel;
  } else if (value.trim().length < 6) {
    return passwordMinLengthLabel;
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return enterConfirmPasswordLabel;
  }
  if (value != password) {
    return passwordConfirmMismatchLabel;
  }
  return null;
}

getUserLocation() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();

    getUserLocation();
  } else if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
      await Geolocator.openLocationSettings();
      getUserLocation();
    } else {
      getUserLocation();
    }
  }
}

/* Future<GeoAddress?> displayPrediction(Prediction? p, BuildContext context) async {
  if (p != null) {
    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: Constant.googleApiKey);

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    String zipcode = "";
    GeoAddress address = GeoAddress();

    address.placeId = p.placeId;

    for (AddressComponent component in detail.result.addressComponents) {
      if (component.types.contains('locality')) {
        address.city = component.longName;
      }
      if (component.types.contains('administrative_area_level_2')) {
        address.district = component.longName;
      }
      if (component.types.contains('administrative_area_level_1')) {
        address.state = component.longName;
      }
      if (component.types.contains('country')) {
        address.country = component.longName;
      }
      if (component.types.contains('postal_code')) {
        zipcode = component.longName;
      }
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    //if zipcode not found
    if (zipcode.trim().isEmpty) {
      zipcode = await getZipCode(lat, lng, context);
    }
//
    address.address = detail.result.formattedAddress;
    address.lattitud = lat;
    address.longitude = lng;
    address.zipcode = zipcode;
    return address;
  }
  return null;
} */

/* getZipCode(double lat, double lng, BuildContext context) async {
  String zipcode = "";
  var result = await sendApiRequest(
    apiName: "${Constant.apiGeoCode}$lat,$lng",
    params: {},
    isPost: false,
  );
  if (result != null) {
    var getData = json.decode(result);
    if (getData != null) {
      Map data = getData['results'][0];
      List addressInfo = data['address_components'];
      for (var info in addressInfo) {
        List type = info['types'];
        if (type.contains('postal_code')) {
          zipcode = info['long_name'];
          break;
        }
      }
    }
  }
  return zipcode;
} */

/* getPlaceName(String placeId, BuildContext context) async {
  String placeName = "";
  var result = await sendApiRequest(
    apiName: "${Constant.apiGeoCodePlaceNameByPlaceId}$placeId",
    params: {},
    isPost: false,
  );
  if (result != null) {
    Map<String, dynamic> getData = json.decode(result);
    Map<String, dynamic> data = Map.from(getData['result']);
    placeName = data['name'];
  }
  return placeName;
} */

Future<Position> determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  } else if (permission == LocationPermission.deniedForever) {
    return Future.error('Location Not Available');
  }

  return await Geolocator.getCurrentPosition();
}

/* Future<Map<String, String>> getStoreAddressFromMap(LatLng currentLocation, BuildContext context) async {
  try {
    Map<String, dynamic> response = json.decode(
      await sendApiRequest(
        apiName: "${Constant.apiGeoCode}${currentLocation.latitude},${currentLocation.longitude}",
        params: {},
        isPost: false,
      ),
    );

    final possibleLocations = response['results'] as List;
    Map location = {};
    String street = '';
    String city_id = Constant.session.getData(SessionManager.city_id);
    String state = '';
    String latitude = currentLocation.latitude.toString();
    String longitude = currentLocation.latitude.toString();
    String place_name = '';
    String formatted_address = '';

    if (possibleLocations.isNotEmpty) {
      for (var locationFullDetails in possibleLocations) {
        Map latLng = Map.from(locationFullDetails['geometry']['location']);
        double lat = double.parse(latLng['lat'].toString());
        double lng = double.parse(latLng['lng'].toString());
        place_name = await getPlaceName(locationFullDetails['place_id'], context);
        formatted_address = locationFullDetails['formatted_address'];
        if (lat == currentLocation.latitude && lng == currentLocation.longitude) {
          location = Map.from(locationFullDetails);
          break;
        }
      }
      //If we could not find location with given lat and lng
      if (location.isNotEmpty) {
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('sublocality') && street.isEmpty) {
              street = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('administrative_area_level_1') && state.isEmpty) {
              state = component['long_name'].toString();
            }
          }
        }
      } else {
        location = Map.from(possibleLocations.first);
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('sublocality') && street.isEmpty) {
              street = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('administrative_area_level_1') && state.isEmpty) {
              state = component['long_name'].toString();
            }
          }
        }
      }

      return {
        ApiAndParams.street: street.toString().length > 0 ? street.toString() : place_name.toString(),
        ApiAndParams.city_id: city_id.toString(),
        ApiAndParams.state: state.toString(),
        ApiAndParams.latitude: latitude.toString(),
        ApiAndParams.longitude: longitude.toString(),
        ApiAndParams.place_name: place_name.toString(),
        ApiAndParams.formatted_address: formatted_address.toString()
      };
    } else {
      return {"": ""};
    }
  } on SocketException {
    await Future.delayed(const Duration(milliseconds: 1800));
    throw SocketException('No Internet Connection');
  } catch (e) {
    showMessage(context, e.toString(), MessageType.error);
    return {"": ""};
  }
} */

/* Future<Map<String, dynamic>> getCityNameAndAddress(LatLng currentLocation, BuildContext context) async {
  try {
    Map<String, dynamic> response = json.decode(
      await sendApiRequest(
        apiName: "${Constant.apiGeoCode}${currentLocation.latitude},${currentLocation.longitude}",
        params: {},
        isPost: false,
      ),
    );

    final possibleLocations = response['results'] as List;
    Map location = {};
    String cityName = '';
    String stateName = '';
    String pinCode = '';
    String countryName = '';
    String landmark = '';
    String area = '';

    if (possibleLocations.isNotEmpty) {
      for (var locationFullDetails in possibleLocations) {
        Map latLng = Map.from(locationFullDetails['geometry']['location']);
        double lat = double.parse(latLng['lat'].toString());
        double lng = double.parse(latLng['lng'].toString());
        if (lat == currentLocation.latitude && lng == currentLocation.longitude) {
          location = Map.from(locationFullDetails);
          break;
        }
      }
      //If we could not find location with given lat and lng
      if (location.isNotEmpty) {
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') && cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('administrative_area_level_1') && stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') && countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') && pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') && landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') && area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      } else {
        location = Map.from(possibleLocations.first);
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') && cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('administrative_area_level_1') && stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') && countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') && pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') && landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') && area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      }

      return {
        'address': possibleLocations.first['formatted_address'],
        'city': cityName,
        'state': stateName,
        'pin_code': pinCode,
        'country': countryName,
        'area': area,
        'landmark': landmark,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      };
    }
    return {};
  } on SocketException {
    await Future.delayed(const Duration(milliseconds: 1800));
    throw SocketException('No Internet Connection');
  } catch (e) {
    showMessage(context, e.toString(), MessageType.error);
    return {};
  }
} */

Future getFileFromDevice() async {
  String path = "";
  await FilePicker.platform
      .pickFiles(
          allowMultiple: false, allowCompression: true, type: FileType.custom, allowedExtensions: ["jpg", "jpeg", "png"], lockParentWindow: true)
      .then((value) {
    path = value!.paths.first.toString();
  });
  return path;
}

phoneValidation(String value, String msg) {
  String pattern = r'[0-9]';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty || !regExp.hasMatch(value) || value.trim().length >= 16 || value.trim().length < Constant.minimumRequiredMobileNumberLength) {
    return msg;
  }
  return null;
}

/* String getCurrencyFormat(double amount) {
  return NumberFormat.currency(symbol: Constant.currency, decimalDigits: int.tryParse(Constant.currencyDecimalPoint)??2, name: Constant.currencyCode)
      .format(amount);
} */
/* String getCurrencyFormat(double amount) {
  int maxDecimal = int.tryParse(Constant.currencyDecimalPoint) ?? 2;

  String value = amount.toString();

  if (value.contains(".")) {
    List<String> parts = value.split(".");
    if (parts[1].length > maxDecimal) {
      value = "${parts[0]}.${parts[1].substring(0, maxDecimal)}";
    }
  }

  return "${Constant.currency}$value";
} */
String getCurrencyFormat(double amount) {
  int maxDecimal = int.tryParse(Constant.currencyDecimalPoint) ?? 2;

  String value = amount.toString();
  int decimalDigits = 0;

  if (value.contains(".")) {
    decimalDigits = value.split(".")[1].length;
  }

  if (decimalDigits > maxDecimal) {
    decimalDigits = maxDecimal;
  }

  return NumberFormat.currency(symbol: Constant.currency, decimalDigits: decimalDigits, name: Constant.currencyCode).format(amount);
}

maskSensitiveInformation(text) {}

String getTranslatedValue(BuildContext context, String key) {
  return context.read<LanguageProvider>().currentLanguage[key] ?? context.read<LanguageProvider>().currentLocalOfflineLanguage[key] ?? key;
}

/* Future<bool> hasStoragePermissionGiven() async {
  try {
    if (Platform.isIOS) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    }
//if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    } else {
      bool permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.photos.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    }
  } on SocketException {
    await Future.delayed(const Duration(milliseconds: 1800));
    throw SocketException('No Internet Connection');
  } catch (e) {
    return false;
  }
} */

Future<bool> hasStoragePermissionGiven() async {
    if (Platform.isIOS) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    }
    //if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      // For Android < 13, use legacy storage permission
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    } else {
      // For Android 13+, no permission needed for app-specific storage or Downloads via MediaStore
      // Return true as we'll handle downloads through scoped storage
      return true;
    }
  }

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map(
        (str) => str.toCapitalized(),
      )
      .join(' ');
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;
}

extension StringParsing on String {
  double? get toDouble => double.tryParse(this) ?? 0.0;

  double? get toInt => double.tryParse(this) ?? 0;

  int get toStringToInt => int.tryParse(this) ?? 0;

  String get currency => NumberFormat.currency(
          symbol: Constant.currency, decimalDigits: int.tryParse(Constant.currencyDecimalPoint.toString())??2, name: Constant.currencyCode)
      .format(this.toDouble);
}

extension StringToDateTimeFormatting on String {
  DateTime toDate({String format = 'd MMM y, hh:mm a'}) {
    try {
      return DateTime.parse(this).toLocal();
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return DateTime.now();
    }
  }

  String formatDate({String inputFormat = 'yyyy-MM-dd', String outputFormat = 'd MMM y, hh:mm a'}) {
    try {
      DateTime dateTime = toDate(format: inputFormat);
      return DateFormat(outputFormat).format(dateTime);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return this; // Return the original string if there's an error
    }
  }
}

class CustomNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits (0-9)
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (RegExp(r'^[0-9]*$').hasMatch(newValue.text)) {
      // Allow a single '0', but prevent multiple leading zeros
      if (newValue.text == '0') {
        return newValue; // Allow the single zero
      } else if (newValue.text.length > 1 && newValue.text.startsWith('0') && newValue.text[1] == '0') {//if (newValue.text.startsWith('0') && newValue.text.length > 1) {
        return oldValue; // Reject if it starts with multiple zeros
      } else {
        return newValue; // Accept valid inputs
      }
    } else {
      return oldValue; // Reject invalid inputs
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange}) : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

extension ValidateNullString on String {
  String checkNullString() => (this == "null" ? "" : this).toString();
}

//save image in local
Future<File?> saveFileToLocalStorage(File file) async {
  /* try {
    final directory = await getApplicationDocumentsDirectory();
    final newPath = "${directory.path}/${file.path.split('/').last}";
    return await file.copy(newPath);
  } catch (e) {
    if (kDebugMode) print("Error saving file locally: $e");
    return null;
  } */
  try {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = file.path.split('/').last;
    final newPath = '${directory.path}/$fileName';
    return await file.copy(newPath);
  } catch (e) {
    debugPrint("Save error: $e");
    return null;
  }
}
