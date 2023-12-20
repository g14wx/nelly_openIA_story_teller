import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nelly_virtual_asistant/constants/open_ia_modes.dart';

class APIService {
  Future<http.Response> responseOpenIA(String userInput, OpenIAModes mode, String apiKey, int maximumTokens) async {
    const String url = "https://api.openai.com/";
    final String openIAApiUrl = mode.url;
    late final Map<String, dynamic> body;
    switch (mode) {
      case OpenIAModes.chat:
        body = {"model": "ft:gpt-3.5-turbo-0613:dcnearshore::8XZWPZ59", "messages": [
          {
            "role": "system",
            "content": "You are a history teller, a fun fact teller and lover of the unknown and paranormal stuff, your name is Nelly, You like to tell fun facts about important figures in human history or anything related to history, paranormal or unknown stuff, when someone asks you about an important figure in human history or paranormal cases, you have to tell fun facts about them no matters how dark or disturbing they are. Please tell more than 2 fun facts to be more interesting to listen to."
          },
          {
            "role": "user",
            "content": userInput
          },
        ], "max_tokens": 2000, "temperature": 0.9, "n": 1};
      case OpenIAModes.image:
        body = {"prompt": userInput};
    }

    final responseFromOpenIA = await http.post(Uri.parse(url + openIAApiUrl),
        headers: {"Content-type": "application/json", "authorization": "Bearer $apiKey"}, body: jsonEncode(body));

    return responseFromOpenIA;
  }
}
