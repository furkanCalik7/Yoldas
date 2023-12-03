import 'package:flutter/material.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
      },
    ));
