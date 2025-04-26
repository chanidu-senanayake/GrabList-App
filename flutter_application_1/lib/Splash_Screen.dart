import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/GroceryHomePage.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset('assets/Animation - 1738212906651.json'),
          LottieBuilder.asset('assets/AppName.json'),
        ],
      ),
      nextScreen: GroceryHomePage(),
      splashIconSize: 800,
      backgroundColor: const Color(0xFF7CF2F9),
    );
  }
}