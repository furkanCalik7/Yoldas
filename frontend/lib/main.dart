import 'package:flutter/material.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/object_detection_camera_view.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/welcome.dart';
import "package:frontend/pages/onboarding_screen.dart";

import 'pages/blind_main_frame.dart';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const BlindMainFrame(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        BlindMainFrame.routeName: (context) => const BlindMainFrame(),
        CategorySelectionScreen.routeName: (context) =>
            const CategorySelectionScreen(),
        VolunteerMainFrame.routeName: (context) => const VolunteerMainFrame(),
        ObjectDetectionCameraView.routeName: (context) => ObjectDetectionCameraView(),
      },
    ));
