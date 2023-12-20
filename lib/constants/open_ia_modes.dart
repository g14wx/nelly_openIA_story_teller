enum OpenIAModes{
  chat(value: "chat", url: "v1/completions" /*"v1/chat/completions"*/),
  image(value: "image", url: "v1/images/generations");
  const OpenIAModes({required this.value, required this.url});
  final String url;
  final String value;
}