import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nelly_virtual_asistant/constants/open_ia_modes.dart';

part 'speech_to_text_model.freezed.dart';

@Freezed(equal: false)
class SpeechToTextModel with _$SpeechToTextModel {
  const factory SpeechToTextModel({
    required String recordedAudioString,
    @Default(false) bool isListening,
    @Default(false) bool isInitialized,
    @Default(OpenIAModes.chat) OpenIAModes selectedOpenIAMode,
    @Default(false) bool isLoadingRequestFromOpenIAApi,
    @Default("") String errorFromApi,
    @Default(false) bool errorFromApiResponse,
    @Default("") String successResponseFromOpenIA,
    @Default([]) List<String> selectedLanguageForRecognition
}) = _SpeechToTextModel;
}
