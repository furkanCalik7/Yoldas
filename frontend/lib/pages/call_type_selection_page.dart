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

import '../custom_widgets/appbars/appbar_custom.dart';
import '../custom_widgets/colors.dart';

class CallTypeSelectionScreen extends StatefulWidget {
  const CallTypeSelectionScreen({Key? key}) : super(key: key);

  static const String routeName = "/call_type_selection_screen";

  @override
  _CallTypeSelectionScreenState createState() => _CallTypeSelectionScreenState();
}

class _CallTypeSelectionScreenState extends State<CallTypeSelectionScreen> {
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

  Future<CallRequestResponse> sendConsultancyCall() async {
    try {
      String accessToken =
          await SecureStorageManager.read(key: StorageKey.access_token) ??
              "N/A";
      CallRequest callRequest;

      callRequest = CallRequest(
          isQuickCall: false, category: "", isConsultancyCall: true);
      this.callRequest = callRequest;

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
    return Scaffold(
      appBar: AppbarCustom(
        title: "Arama Türünü Seçin",
      ),
      body: isLoadingForCallId
            ? const Center(child: CircularProgressIndicator()) :
      Container(
      decoration: getBackgroundDecoration(),
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TappableIcon(
                action: () {
                  Navigator.pushNamed(
                      context, CategorySelectionScreen.routeName);
                },
                iconData: Icons.volunteer_activism,
                size: 150,
                text: "Gönüllü Ara",
              ),
              TappableIcon(
                action: () {
                  setState(() {
                    isLoadingForCallId = true;
                  });
                  sendConsultancyCall().then((callRequestResponse) {
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
                iconData: Icons.blind,
                size: 150,
                text: "Görme Engelli Ara",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
