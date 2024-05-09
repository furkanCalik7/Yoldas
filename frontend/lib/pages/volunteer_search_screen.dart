import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/controller/webrtc/dto/call_cancel.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/controller/webrtc/dto/call_request_response.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';

class VolunteerSearchScreen extends StatefulWidget {
  VolunteerSearchScreen(
      {Key? key, required this.callRequest, required this.callId})
      : super(key: key);

  final CallRequest callRequest;
  final String callId;

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
    sendSearchSessionDetails();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("tr-TR");

    if (!widget.callRequest.isConsultancyCall!) {
      flutterTts.speak("Uygun gönüllü aranıyor");
    } else {
      flutterTts.speak("Uygun görme engelli aranıyor");
    }

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

  Future<void> sendSearchSessionDetails() async {
    String accessToken =
        SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
            await SecureStorageManager.read(key: StorageKey.access_token) ??
            "N/A";
    await ApiManager.post(
      path: "/calls/call/${widget.callId}/search-session",
      bearerToken: accessToken,
      body: widget.callRequest.toJson(),
    );
  }

  void cancelCall(String callId) async {
    String accessToken =
        SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
            await SecureStorageManager.read(key: StorageKey.access_token) ??
            "N/A";
    await ApiManager.post(
      path: "/calls/call/cancel",
      bearerToken: accessToken,
      body: CallCancel(callID: callId).toJSON(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                textAlign: TextAlign.center,
                widget.callRequest.isConsultancyCall!
                    ? 'Uygun görme engelli aranıyor...'
                    : 'Uygun gönüllü aranıyor...',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: textColorLight,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Ink(
              decoration: const ShapeDecoration(
                color: redIconButtonColor,
                // Set the background color of the IconButton
                shape: CircleBorder(),
              ),
              child: IconButton(
                onPressed: () {
                  if (widget.callId != null) {
                    cancelCall(widget.callId);
                  }
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.call_end, size: 50, color: Colors.white),
                iconSize: 50,
                // Adjust the size of the icon as needed
                padding: const EdgeInsets.all(10),
                // Adjust the padding as needed
                splashRadius: 28,
                // Set the splash radius as needed
                tooltip: "Aramayı iptal et",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
