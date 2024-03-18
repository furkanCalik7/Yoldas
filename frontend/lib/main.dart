import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controller/test_page.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/evaluation_page.dart';
import 'package:frontend/pages/initial_screen.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/object_detection_camera_view.dart';
import "package:frontend/pages/onboarding_screen.dart";
import 'package:frontend/pages/text_recognition_view.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/welcome.dart';

import 'firebase_options.dart';
import 'pages/blind_main_frame.dart';
import 'pages/call_main_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializationPage(),
        //'/': (context) => const CallMainFrame(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        BlindMainFrame.routeName: (context) => const BlindMainFrame(),
        CategorySelectionScreen.routeName: (context) =>
            const CategorySelectionScreen(),
        VolunteerMainFrame.routeName: (context) => const VolunteerMainFrame(),
        CallMainFrame.routeName: (context) => const CallMainFrame(),
        Welcome.routeName: (context) => const Welcome(),
        EvaluationPage.routeName: (context) => const EvaluationPage(),
        ObjectDetectionCameraView.routeName: (context) =>
            ObjectDetectionCameraView(),
        TextRecognitionCameraView.routeName: (context) =>
            TextRecognitionCameraView(),
        MyHomePage.routeName: (context) => MyHomePage(),
      },
    ),
  );
}
