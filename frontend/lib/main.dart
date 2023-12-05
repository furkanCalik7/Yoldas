import 'package:flutter/material.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const Login(),
        '/verification': (context) => const PinCodeVerificationScreen()
      },
    ));
