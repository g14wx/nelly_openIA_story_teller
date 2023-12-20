import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nelly_virtual_asistant/constants/open_ia_modes.dart';
import 'package:nelly_virtual_asistant/services/speech_to_text_service/models/speech_to_text_model/speech_to_text_model.dart';
import 'package:nelly_virtual_asistant/services/speech_to_text_service/speech_to_text_provider.dart';
import 'package:typewritertext/typewritertext.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final indexLanguageRecognition = useRef(0);

    final speechToTextProvider = ref.watch(speechToTextProviderProvider);

    ref.listen<SpeechToTextModel>(speechToTextProviderProvider, (previous, next) {
      if (!next.isListening && next.recordedAudioString.isNotEmpty && !next.isLoadingRequestFromOpenIAApi) {
        debugPrint("-------------------------------------------------------------------------");
        debugPrint("IS_LISTENING = previous: ${previous?.isListening}, next: ${next.isListening}");
        debugPrint("send the request to the api: ${next.recordedAudioString}");
        debugPrint("-------------------------------------------------------------------------");
        // reset text
        ref.read(speechToTextProviderProvider.notifier).makeRequestToApiToken();
      } else if (next.errorFromApiResponse && next.errorFromApi.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorFromApi)));
      } else if(next.successResponseFromOpenIA.isNotEmpty){
          debugPrint("===========================.....((())).....===========================");
          debugPrint(next.successResponseFromOpenIA);
      }
    });

    useEffect(() {
      return null;
    }, []);

    final TextEditingController textController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              BoxDecoration(gradient: LinearGradient(colors: [Colors.purpleAccent.shade100, Colors.deepPurple])),
        ),
        title: Image.asset(
          "assets/images/logo.png",
          width: 140,
        ),
        titleSpacing: 10,
        elevation: 0,
        actions: [
          // chat

          Padding(
            padding: const EdgeInsets.only(right: 4, top: 4),
            child: InkWell(
              onTap: () {
                if (indexLanguageRecognition.value == 2) {
                  indexLanguageRecognition.value = 0;
                } else {
                  indexLanguageRecognition.value += 1;
                }
                ref.read(speechToTextProviderProvider.notifier).changeLanguageRecognition(languages: indexLanguageRecognition.value == 1 ? ["en-US", "en-SV"] : indexLanguageRecognition.value == 2 ? ["es-ES", "es-SV", "es-US"] : []);
              },
              child: Text(indexLanguageRecognition.value == 1 ? "🇺🇸" : indexLanguageRecognition.value == 2 ? "🇪🇸" : "🏳️", style: TextStyle(fontSize: 35)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 4, top: 4),
            child: InkWell(
              onTap: () {
                ref.read(speechToTextProviderProvider.notifier).setOpenIAMode(mode: OpenIAModes.chat);
              },
              child: Icon(
                Icons.chat,
                size: 40,
                color: speechToTextProvider.selectedOpenIAMode == OpenIAModes.chat ? Colors.white : Colors.grey,
              ),
            ),
          ),
          // image

          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: InkWell(
              onTap: () {
                ref.read(speechToTextProviderProvider.notifier).setOpenIAMode(mode: OpenIAModes.image);
              },
              child: Icon(
                Icons.image,
                size: 40,
                color: speechToTextProvider.selectedOpenIAMode == OpenIAModes.image ? Colors.white : Colors.grey,
              ),
            ),
          )
        ],
      ),
      body: speechToTextProvider.isLoadingRequestFromOpenIAApi
          ? Center(
            child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size.fromWidth(400)),
                child: const Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("I'm thinking...")
                      ],
                    ),
                  ),
                ),
              ),
          )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // image
                    if (speechToTextProvider.isInitialized)
                      Center(
                        child: InkWell(
                          onTap: () {
                            speechToTextProvider.isListening
                                ? ref.read(speechToTextProviderProvider.notifier).stopListeningNow()
                                : ref.read(speechToTextProviderProvider.notifier).startListeningNow();
                          },
                          child: ConstrainedBox(
                              constraints: BoxConstraints.loose(const Size(300, 300)),
                              child: speechToTextProvider.isListening
                                  ? LoadingAnimationWidget.beat(color: Colors.deepPurple, size: 300)
                                  : Image.asset("assets/images/assistant_icon.png")),
                        ),
                      ),
                    const SizedBox(
                      height: 50,
                    ),

                    // text field
                    ConstrainedBox(
                      constraints: BoxConstraints.loose(const Size(500, 300)),
                      child: Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: TextField(
                              controller: textController,
                              decoration:
                                  const InputDecoration(border: OutlineInputBorder(), label: Text("how I can help you")),
                            ),
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(speechToTextProviderProvider.notifier).makeRequestToApiToken(text: textController.text);
                              textController.clear();
                            },
                            child: AnimatedContainer(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(shape: BoxShape.rectangle, color: Colors.deepPurpleAccent),
                              duration: const Duration(milliseconds: 5),
                              curve: Curves.bounceInOut,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if(speechToTextProvider.selectedOpenIAMode == OpenIAModes.chat && speechToTextProvider.successResponseFromOpenIA.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints.loose(const Size(500, 300)),
                      child: TypeWriterText.builder(
                          speechToTextProvider.successResponseFromOpenIA,
                          duration: const Duration(milliseconds: 50),
                          builder: (context, value) {
                            return SelectableText(
                                value,
                            );
                          }
                      ),
                    ),
                    if(speechToTextProvider.selectedOpenIAMode == OpenIAModes.image && speechToTextProvider.successResponseFromOpenIA.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints.loose(const Size(500, 300)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Image.network(speechToTextProvider.successResponseFromOpenIA, loadingBuilder: (context, child, loadingProgress) {
                              print(loadingProgress?.cumulativeBytesLoaded);
                              if (loadingProgress != null) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return child;
                            },)),
                            if(!kIsWeb)
                            ElevatedButton(onPressed: () {
                              ImageDownloader.downloadImage(speechToTextProvider.successResponseFromOpenIA).then((value) {
                                const snackBar = SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text("Image successfully downloaded!", style: TextStyle(color: Colors.white),),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              });
                            },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple
                              ),
                              child: const Text('Download image', style: TextStyle(color: Colors.white),),)
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/sound.png"),
        ),
      ),
    );
  }
}
