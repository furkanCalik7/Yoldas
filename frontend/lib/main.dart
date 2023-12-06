import 'package:flutter/material.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";
import 'package:frontend/pages/routes.dart';

import 'pages/blind_main_frame.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => const OnboardingScreen(),
        Routes.loginScreen: (context) => const Login(),
        Routes.verificationScreen: (context) =>
            const PinCodeVerificationScreen(),
        Routes.onboardingScreen: (context) => const OnboardingScreen(),
        BlindMainFrame.routeName: (context) => const BlindMainFrame(),

      },
    ));
