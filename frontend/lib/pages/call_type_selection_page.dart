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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Arama Türünü Seçin",
      ),
      body: Container(
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
