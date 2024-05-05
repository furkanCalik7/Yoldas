import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/controller/webrtc/constants/call_status.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/controller/webrtc/dto/call_request_response.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/pages/call_main_frame.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';

class BlindHomeScreen extends StatefulWidget {
  const BlindHomeScreen({Key? key}) : super(key: key);

  @override
  _BlindHomeScreenState createState() => _BlindHomeScreenState();
}

class _BlindHomeScreenState extends State<BlindHomeScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late StreamSubscription<DocumentSnapshot> callSubscription;
  late String callId;
  bool isLoadingForCallId = false;
  late CallRequest callRequest;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    callSubscription.cancel();
    super.dispose();
  }

  Future<CallRequestResponse> sendQuickCallRequest() async {
    try {
      String accessToken = SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
          await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";
      callRequest = CallRequest(
          isQuickCall: true, category: "", isConsultancyCall: false);

      final response = await ApiManager.post(
        path: "/calls/call",
        bearerToken: accessToken,
        body: callRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return CallRequestResponse.fromJSON(jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arama isteği gönderilemedi.'),
          ),
        );
        setState(() {
          isLoadingForCallId = false;
        });
        flutterTTs.speak("Arama isteği gönderilemedi");
        throw Exception(
            'Failed to send quick call request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arama isteği gönderilemedi.'),
        ),
      );
      setState(() {
        isLoadingForCallId = false;
      });
      flutterTTs.speak("Arama isteği gönderilemedi");
      throw e;
    }
  }

  void registerCallStatus(String callId, BuildContext context) {
    callSubscription = db
        .collection("CallCollection")
        .doc(callId)
        .snapshots()
        .listen((snapshot) {
      print('(debug) Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data["status"] == CallStatus.IN_CALL.toString()) {
        print("Call started");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CallMainFrame(
              callId: callId,
              callActionType: "start",
            ),
          ),
          ModalRoute.withName('/'),
        );
        callSubscription.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoadingForCallId
          ? const Center(child: CircularProgressIndicator())
          : // Show loading ind:
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TappableIcon(
                  action: () {
                    setState(() {
                      isLoadingForCallId = true;
                    });
                    sendQuickCallRequest().then((callRequestResponse) {
                      callId = callRequestResponse.callID;
                      registerCallStatus(callRequestResponse.callID, context);

                      Map<String, dynamic> args = {
                        'callRequest': callRequest,
                        'callId': callId
                      };

                      Navigator.pushNamed(
                        context,
                        VolunteerSearchScreen.routeName,
                        arguments: args,
                      ).then((result) {
                        if(result == true) {
                          setState(() {
                            isLoadingForCallId = false;
                          });
                        }
                      });
                    });
                  },
                  iconData: Icons.search,
                  size: 150,
                  text: "Hızlı Arama Yap",
                ),
                TappableIcon(
                  action: () {
                    Navigator.pushNamed(
                        context, CategorySelectionScreen.routeName);
                  },
                  iconData: Icons.person_search,
                  size: 150,
                  text: "Özel Arama Yap",
                ),
              ],
            ),
    );
  }
}
