import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nelly_virtual_asistant/constants/env_constants.dart';
import 'package:nelly_virtual_asistant/constants/open_ia_modes.dart';
import 'package:nelly_virtual_asistant/services/api_service/api_service.dart';
import 'package:nelly_virtual_asistant/services/speech_to_text_service/models/speech_to_text_model/speech_to_text_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

part 'speech_to_text_provider.g.dart'; // Generated code

@riverpod
class SpeechToTextProvider extends _$SpeechToTextProvider {
  late final SpeechToText speechToTextInstance;
  late final APIService _apiService;
  List<LocaleName> _locales = [];

  final TextToSpeech _tts = TextToSpeech();

  SpeechToTextProvider() {
    _apiService = APIService();
    speechToTextInstance = SpeechToText();
    _initializeSpeechToTextInstance();
  }

  _initializeSpeechToTextInstance() async {
    final isInitialized = await speechToTextInstance.initialize();
    _locales = await speechToTextInstance.locales();
    state = state.copyWith(isInitialized: isInitialized);
  }

  void startListeningNow() async {
    state = state.copyWith(isListening: true, successResponseFromOpenIA: "");
    if (_locales.isNotEmpty && _locales.where((element) => state.selectedLanguageForRecognition.contains(element.localeId)).isNotEmpty) {
      await speechToTextInstance.listen(onResult: _onSpeechToTextResult, localeId: state.selectedLanguageForRecognition.first);
    } else {
      await speechToTextInstance.listen(onResult: _onSpeechToTextResult);
    }
  }

  void stopListeningNow({String? text}) async {
    try {
      await speechToTextInstance.stop();
    } catch (e) {
      debugPrint(e.toString());
    }
    state = state.copyWith(isListening: false, recordedAudioString: text ?? "");
  }

  _onSpeechToTextResult(SpeechRecognitionResult recognitionResult) {
    final result = recognitionResult.recognizedWords;
    final isNotListening = speechToTextInstance.isNotListening;
    if (isNotListening) {
      stopListeningNow(text: result);
    } else {
      state = state.copyWith(recordedAudioString: result);
    }
    if (kDebugMode) {
      print("finish listening: $isNotListening");
      print("Result speech recognition: $result");
    }
  }

  @override
  SpeechToTextModel build() {
    // Initialize the state when the provider is first initialized
    return const SpeechToTextModel(recordedAudioString: "");
  }

  void changeText({required String text}) {
    state = state.copyWith(recordedAudioString: text);
  }

  void resetRecordedAudioString() {
    state = state.copyWith(recordedAudioString: "");
  }

  void makeRequestToApiToken({String? text}) async {
    final apiKey = dotenv.get(EnvConstants.openIAKey);
    final recordedAudioString = text ?? state.recordedAudioString;
    state = state.copyWith(
        isLoadingRequestFromOpenIAApi: true,
        recordedAudioString: "",
        errorFromApiResponse: false,
        errorFromApi: "",
        successResponseFromOpenIA: "");
    try {
      final response = await _apiService.responseOpenIA(recordedAudioString, state.selectedOpenIAMode, apiKey, 2000);
      if (response.statusCode == 401) {
        state = state.copyWith(
            errorFromApi: "Error from api string, you are not allowed to request any data",
            errorFromApiResponse: true, recordedAudioString: "");
      }

      final responseApi = jsonDecode(response.body);
      switch (state.selectedOpenIAMode) {
        case OpenIAModes.chat:
          state = state.copyWith(
              successResponseFromOpenIA: utf8.decode(responseApi["choices"][0]["message"]["content"].toString().codeUnits), isLoadingRequestFromOpenIAApi: false, recordedAudioString: "");
          _tts.speak(state.successResponseFromOpenIA);
        case OpenIAModes.image:
          state = state.copyWith(successResponseFromOpenIA: responseApi["data"][0]["url"], isLoadingRequestFromOpenIAApi: false, recordedAudioString: "");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      state = state.copyWith(errorFromApi: "Error from api string", errorFromApiResponse: true, recordedAudioString: "", isLoadingRequestFromOpenIAApi: false);
    }
    // resetRecordedAudioString();
  }

  void setOpenIAMode({required OpenIAModes mode}){
    state = state.copyWith(selectedOpenIAMode: mode, successResponseFromOpenIA: "");
  }

  void changeLanguageRecognition({required List<String> languages}) {
    state = state.copyWith(selectedLanguageForRecognition: languages, successResponseFromOpenIA: "");
  }
}
