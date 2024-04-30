import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/currency_recognition_camera_view.dart';
import 'package:frontend/pages/evaluation_page.dart';
import 'package:frontend/pages/initial_screen.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/notification_screen.dart';
import "package:frontend/pages/onboarding_screen.dart";
import 'package:frontend/pages/text_recognition_view.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';
import 'package:frontend/pages/welcome.dart';

import 'firebase_options.dart';
import 'pages/blind_main_frame.dart';
import 'pages/call_main_frame.dart';

final navigationKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  print("API Location: $API_URL");
  runApp(
    MaterialApp(
      initialRoute: '/',
      navigatorKey: navigationKey,
      routes: {
        '/': (context) => const InitializationPage(),
        //'/': (context) => const BlindMainFrame(),
        //'/': (context) => const CallMainFrame(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        BlindMainFrame.routeName: (context) => const BlindMainFrame(),
        CategorySelectionScreen.routeName: (context) =>
            const CategorySelectionScreen(),
        VolunteerMainFrame.routeName: (context) => const VolunteerMainFrame(),
        // '/callMainFrameWithParams': (context) {
        //   final Map<String, dynamic> args = ModalRoute.of(context)!
        //       .settings
        //       .arguments as Map<String, dynamic>;
        //   return CallMainFrame(
        //     callId: args['callId'],
        //     callActionType: args['call_action_type'],
        //   );
        // },
        // CallMainFrame.routeName: (context) => CallMainFrame(),
        Welcome.routeName: (context) => const Welcome(),
        TextRecognitionCameraView.routeName: (context) =>
            TextRecognitionCameraView(),
        CurrencyRecognitionCameraView.routeName: (context) =>
            CurrencyRecognitionCameraView(),
        VolunteerSearchScreen.routeName: (context) => VolunteerSearchScreen(),
        NotificationScreen.routeName: (context) => const NotificationScreen(),
      },
    ),
  );
}
