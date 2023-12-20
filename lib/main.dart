import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nelly_virtual_asistant/constants/app_constants.dart';
import 'package:nelly_virtual_asistant/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: AppConstants.envFile);

  await Permission.mediaLibrary.request();
  await Permission.microphone.request();
  await Permission.audio.request();
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.bluetoothAdvertise.request();
  await Permission.audio.request();
  await Permission.speech.request();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OpenIA ChatGPT Dale-E",
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const HomeScreen(),
    );
  }
}
