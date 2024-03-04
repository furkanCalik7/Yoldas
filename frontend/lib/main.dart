import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/currency_recognition_camera_view.dart';
import 'package:frontend/pages/evaluation_page.dart';
import 'package:frontend/pages/image_caption_view.dart';
import 'package:frontend/pages/initial_screen.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/object_detection_camera_view.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/pages/text_recognition_view.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";
import 'package:frontend/pages/evaluation_page.dart';
import 'package:frontend/utility/login.dart';
import 'pages/blind_main_frame.dart';
import 'pages/call_main_frame.dart';

void main() async {
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
        ObjectDetectionCameraView.routeName: (context) => ObjectDetectionCameraView(),
        TextRecognitionCameraView.routeName: (context) => TextRecognitionCameraView(),
        CurrencyRecognitionCameraView.routeName: (context) => CurrencyRecognitionCameraView(),
        ImageCaptionView.routeName: (context) => ImageCaptionView(),
      },
    ),
  );
}
