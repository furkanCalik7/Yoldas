import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controller/notification_handler.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/settings_screen.dart';
import 'package:frontend/util/secure_storage.dart';

import '../controller/webrtc/dto/call_accept.dart';
import '../controller/webrtc/dto/call_accept_response.dart';
import '../custom_widgets/appbars/appbar_custom.dart';
import '../main.dart';
import '../util/api_manager.dart';
import 'ai_model_selection_page.dart';
import 'call_main_frame.dart';



class BlindMainFrame extends StatefulWidget {
  const BlindMainFrame({super.key});

  static const String routeName = "/blind_main_frame";

  @override
  State<BlindMainFrame> createState() => _BlindMainFrameState();
}

class _BlindMainFrameState extends State<BlindMainFrame> {
  int _selectedIndex = 1;

  static const List<String> labels = ["Yapay Zeka", "Arama", "Ayarlar"];
  static final List<Widget> _widgetOptions = <Widget>[
    AIModelSelectionPage(),
    BlindHomeScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    String? phoneNumber =
        SecureStorageManager.readFromCache(key: StorageKey.phone_number) ??
            await SecureStorageManager.read(key: StorageKey.phone_number);
    if (phoneNumber == null) return;
    await NotificationHandler().initializeNotifications(phoneNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: labels[_selectedIndex],
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            label: "Yapay Zeka",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_sharp),
            label: "Arama",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Ayarlar",
          ),
        ],
        backgroundColor: secondaryColor,
        currentIndex: _selectedIndex,
        selectedItemColor: tertiaryColor,
        unselectedItemColor: textColorLight,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
