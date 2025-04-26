import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Splash_Screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDk35srWxS1hhYrtUtElAFnZtAHdMd1s4Q",
            appId: "1:988256461152:web:1eeaf01333eed139e4be05",
            messagingSenderId: "988256461152",
            projectId: "finalyearproject-5a1e2",
            storageBucket: "finalyearproject-5a1e2.appspot.com"));
  } else if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDk35srWxS1hhYrtUtElAFnZtAHdMd1s4Q",
            appId: "1:988256461152:android:1eeaf01333eed139e4be05",
            messagingSenderId: "988256461152",
            projectId: "finalyearproject-5a1e2",
            storageBucket: "finalyearproject-5a1e2.appspot.com"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
