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
import 'package:http/http.dart' as http;

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

  List<String> possibleCategories = [];
  int selectedIndex = 0;
  bool isLoading = true; // New variable to track loading status
  late StreamSubscription<DocumentSnapshot> callSubscription;
  late String callId;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getAllAbilities();

  }

  Future<void> getAllAbilities() async {
    String path = '/users/get_all_abilities';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
    };

    http.Response response = await ApiManager.get(
      path,
      headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        possibleCategories = List.from(responseBody.values.toList());
      });
    } else {
      print('ERROR: Status code: ${response.statusCode}');
      setState(() {});
    }
    isLoading = false; // Even in case of error, stop the loading indicator
  }

  Future<CallRequestResponse> sendQuickCallRequest() async {
    try {
      String accessToken =
          await SecureStorageManager.read(key: StorageKey.access_token) ??
              "N/A";
      CallRequest callRequest;

      String selectedCategory = possibleCategories[selectedIndex];
      print(selectedCategory);
      if (selectedCategory == "Psikoloji") {
        callRequest = CallRequest(
            isQuickCall: true,
            category: possibleCategories[selectedIndex],
            isConsultancyCall: true);
      } else {
        callRequest = CallRequest(
            isQuickCall: true,
            category: possibleCategories[selectedIndex],
            isConsultancyCall: false);
      }

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
                    action: () {
                      setState(() {
                        isLoading = true;
                      });
                      sendQuickCallRequest().then((callRequestResponse) {
                        callId = callRequestResponse.callID;
                        registerCallStatus(callRequestResponse.callID, context);

                        Navigator.pushNamed(
                            context, VolunteerSearchScreen.routeName,
                            arguments: {"call_id": callId}).then((result) {
                          if (result == true) {
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
