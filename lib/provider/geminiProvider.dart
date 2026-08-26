import 'package:flutter/material.dart';
import 'package:project/repositories/geminiApi.dart';

enum GeminiGenerationState {
  initial,
  loading,
  loaded,
  error,
}

class GeminiDescriptionProvider extends ChangeNotifier {
  final GeminiRepository repository;

  GeminiDescriptionProvider({required this.repository});

  GeminiGenerationState state = GeminiGenerationState.initial;
  String description = '';
  String message = '';

  Future<bool> generateDescription(String prompt, BuildContext context) async {
    state = GeminiGenerationState.loading;
    notifyListeners();

    try {
      description = await repository.fetchGeneratedDescription(prompt);
      debugPrint("description:$description");
      state = GeminiGenerationState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      message = e.toString();
      debugPrint("description:$message");
      state = GeminiGenerationState.error;
      notifyListeners();
      return false;
    }
  }
}
