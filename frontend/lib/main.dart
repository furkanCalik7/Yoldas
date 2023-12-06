import 'package:flutter/material.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";
import 'package:frontend/pages/routes.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        Routes.loginScreen: (context) => const Login(),
        Routes.verificationScreen: (context) =>
            const PinCodeVerificationScreen(),
        Routes.onboardingScreen: (context) => const OnboardingScreen()
      },
    ));
