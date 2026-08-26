import 'package:flutter/material.dart';
import 'package:project/helper/utils/apiAndParams.dart';
import 'package:project/repositories/policyAndTermsApi.dart';

enum PolicyAndTermsState { initial, loading, loaded, error }

class PolicyAndTermsProvider with ChangeNotifier {

  PolicyAndTermsState _state = PolicyAndTermsState.initial;
  String? _content = "";
  String? _errorMessage = "";

  PolicyAndTermsState get state => _state;
  String? get content => _content;
  String? get errorMessage => _errorMessage;

  Future<void> loadPolicyAndTerms(String type) async {
    _state = PolicyAndTermsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await fetchPolicyAndTerms();
      if (data[ApiAndParams.status].toString() == "1") {
        _content = data[ApiAndParams.data][type];
      _state = PolicyAndTermsState.loaded;} else {
        _errorMessage = data[ApiAndParams.message] ?? "Failed to load data";
        _state = PolicyAndTermsState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = PolicyAndTermsState.error;
    }

    notifyListeners();
  }
}
