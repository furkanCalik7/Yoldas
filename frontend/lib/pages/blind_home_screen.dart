import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    String accessToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";
    CallRequest callRequest;

    callRequest =
        CallRequest(isQuickCall: true, category: "", isConsultancyCall: false);

    final response = await ApiManager.post(
      path: "/calls/call",
      bearerToken: accessToken,
      body: callRequest.toJson(),
    );

    return CallRequestResponse.fromJSON(jsonDecode(response.body));
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TappableIcon(
            action: () {
              sendQuickCallRequest().then((callRequestResponse) {
                callId = callRequestResponse.callID;
                registerCallStatus(callRequestResponse.callID, context);
              });

              Navigator.pushNamed(context, VolunteerSearchScreen.routeName,
                  arguments: {"is_quick_call": true});
            },
            iconData: Icons.search,
            size: 150,
            text: "Hızlı Arama",
          ),
          TappableIcon(
            action: () {
              Navigator.pushNamed(context, CategorySelectionScreen.routeName);
            },
            iconData: Icons.person_search,
            size: 150,
            text: "Özel Arama",
          ),
        ],
      ),
    );
  }
}
