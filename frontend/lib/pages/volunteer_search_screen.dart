import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/controller/webrtc/dto/call_cancel.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/controller/webrtc/dto/call_request_response.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';

class VolunteerSearchScreen extends StatefulWidget {
  VolunteerSearchScreen({Key? key}) : super(key: key);

  @override
  _VolunteerSearchScreenState createState() => _VolunteerSearchScreenState();

  static const String routeName = "/volunteer_search_screen";
}

class _VolunteerSearchScreenState extends State<VolunteerSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  late FlutterTts flutterTts;
  String? callId;

  FirebaseFirestore db = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot<Object?>>? callSubscription;

  double _radius = 30.0; // Radius of circular path

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("tr-TR");
    flutterTts.speak("Uygun gönüllü aranıyor");
    flutterTts.setVoice({"name": "tr-tr-x-ama-local", "locale": "tr-TR"});
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rotationAnimation = Tween<double>(begin: math.pi / 32, end: -math.pi / 32)
        .animate(_animationController);
    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset(0, _radius),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();

    callSubscription?.cancel();
    super.dispose();
  }

  Future<CallRequestResponse> sendCallRequest(Map<String, dynamic> args) async {
    String accessToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";
    CallRequest callRequest;

    if (args["is_quick_call"] != null) {
      callRequest = CallRequest(
          isQuickCall: true, category: "", isConsultancyCall: false);
    } else {
      String category = args["category"];
      if (category == "Psikoloji") {
        callRequest = CallRequest(
            isQuickCall: false, category: category, isConsultancyCall: true);
      } else {
        callRequest = CallRequest(
            isQuickCall: false, category: category, isConsultancyCall: false);
      }
    }

    final response = await ApiManager.post(
      path: "/calls/call",
      bearerToken: accessToken,
      body: callRequest.toJson(),
    );

    return CallRequestResponse.fromJSON(jsonDecode(response.body));
  }

  void cancelCall(String callId) async {
    await ApiManager.post(
      path: "/calls/call/cancel",
      bearerToken:
          await SecureStorageManager.read(key: StorageKey.access_token) ??
              "N/A",
      body: CallCancel(callID: callId).toJSON(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    callId = args["call_id"];


    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.cos(_rotationAnimation.value * 8) * _radius,
                    math.sin(_rotationAnimation.value * 8) * _radius,
                  ),
                  child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Image.asset(
                        "assets/search_icon.png",
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.width * 0.75,
                      )),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Uygun gönüllü aranıyor...',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: textColorLight,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),

            Ink(
              decoration: const ShapeDecoration(
                color: redIconButtonColor, // Set the background color of the IconButton
                shape: CircleBorder(),
              ),
              child: IconButton(
                onPressed: () {
                  if (callId != null) {
                    cancelCall(callId!);
                  }
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.call_end, size: 50, color: Colors.white),
                iconSize: 50, // Adjust the size of the icon as needed
                padding: const EdgeInsets.all(10), // Adjust the padding as needed
                splashRadius: 28, // Set the splash radius as needed
                tooltip: "Aramayı iptal et",
              ),
            ),

          ],
        ),
      ),
    );
  }
}
