import 'package:flutter/material.dart';
import 'package:project/helper/utils/apiAndParams.dart';
import 'package:project/helper/utils/constant.dart';
import 'package:project/helper/utils/generalMethods.dart';
import 'package:project/models/salary.dart';
import 'package:project/repositories/salaryApi.dart';

enum SalaryState {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  error,
}

class SalaryProvider extends ChangeNotifier {
  SalaryState salaryState = SalaryState.initial;
  String message = '';
  List<SalaryData> mySalaries = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getSalaryProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    try {
      if (offset == 0) {
        salaryState = SalaryState.loading;
        mySalaries = [];
        notifyListeners();
      } else {
        salaryState = SalaryState.loadingMore;
        notifyListeners();
      }

      params[ApiAndParams.limit] = Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData = await getSalaryApi(context: context, params: params);

      if (getData[ApiAndParams.status].toString() == "1") {
        totalData = int.tryParse(getData[ApiAndParams.data][ApiAndParams.total]?.toString() ?? "0") ?? 0;
        List<SalaryData> tempSalaries = (getData[ApiAndParams.data][ApiAndParams.salaries] as List)
            .map((e) => SalaryData.fromJson(Map.from(e)))
            .toList();

        if (offset == 0) {
          mySalaries = tempSalaries;
        } else {
          mySalaries.addAll(tempSalaries);
        }

        hasMoreData = totalData > mySalaries.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        salaryState = totalData > 0 ? SalaryState.loaded : SalaryState.empty;
      } else {
        salaryState = SalaryState.error;
      }
      notifyListeners();
    } catch (e) {
      message = e.toString();
      salaryState = SalaryState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }
}
