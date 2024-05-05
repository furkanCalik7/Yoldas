import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/swiper/custom_swiper.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';
import 'package:frontend/util/api_manager.dart';

import '../controller/webrtc/constants/call_status.dart';
import '../controller/webrtc/dto/call_request.dart';
import '../controller/webrtc/dto/call_request_response.dart';
import '../util/secure_storage.dart';
import 'call_main_frame.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  static const String routeName = "/category_selection_screen";

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<IconData> icons = [
    Icons.medical_services_rounded,
    Icons.music_note,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.balance,
    Icons.psychology_alt,
    Icons.school,
    Icons.attach_money,
    Icons.psychology,
    Icons.eco,
  ];

  List<String> possibleCategories = [
    'Sağlık',
    'Müzik',
    'Aşçılık',
    'Alışveriş',
    'Hukuk',
    'Felsefe',
    'Eğitim',
    'Ekonomi',
    'Psikoloji',
    'Botanik'
  ];

  int selectedIndex = 0;
  bool isLoading = false;
  late StreamSubscription<DocumentSnapshot> callSubscription;
  late String callId;
  FirebaseFirestore db = FirebaseFirestore.instance;

  late CallRequest callRequest;

  @override
  void initState() {
    super.initState();
  }

  Future<CallRequestResponse> sendQuickCallRequest() async {
    try {
      String accessToken =
          await SecureStorageManager.read(key: StorageKey.access_token) ??
              "N/A";
      CallRequest callRequest;

      String selectedCategory = possibleCategories[selectedIndex];
      callRequest = CallRequest(
          isQuickCall: true,
          category: possibleCategories[selectedIndex],
          isConsultancyCall: false);

      this.callRequest = callRequest;

      final response = await ApiManager.post(
        path: "/calls/call",
        bearerToken: accessToken,
        body: callRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return CallRequestResponse.fromJSON(jsonDecode(response.body));
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arama isteği gönderilemedi.'),
          ),
        );
        setState(() {
          isLoading = false;
        });
        throw Exception(
            'Failed to send quick call request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions occurred during the process
      print('Error sending quick call request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arama isteği gönderilemedi.'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      // Re-throw the exception if you want to propagate it further
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
      appBar: isLoading ? null :AppbarCustom(
        title: "Kategori Seç",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        padding: const EdgeInsets.all(50),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  SizedBox(
                    height: 250,
                    child: CustomSwiper(
                        titles: possibleCategories,
                        icons: icons,
                        action: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                          flutterTTs.speak(possibleCategories[selectedIndex]);
                        }),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  ButtonMain(
                    text: "Aramayı Başlat",
                    semanticLabel: "${possibleCategories[selectedIndex]} kategorisinde aramayı başlat",
                    action: () {
                      setState(() {
                        isLoading = true;
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
                              isLoading = false;
                            });
                          }
                        });
                      });
                    },
                    height: MediaQuery.of(context).size.height * 0.075,
                  ),
                ],
              ),
      ),
    );
  }
}
