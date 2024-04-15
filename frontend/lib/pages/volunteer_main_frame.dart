import 'package:flutter/material.dart';
import 'package:frontend/controller/notification_handler.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/settings_screen.dart';
import 'package:frontend/pages/volunteer_home_screen.dart';
import 'package:frontend/util/secure_storage.dart';

import '../custom_widgets/appbars/appbar_custom.dart';

class VolunteerMainFrame extends StatefulWidget {
  const VolunteerMainFrame({super.key});
  static const String routeName = "/volunteer_main_frame";
  @override
  State<VolunteerMainFrame> createState() => _VolunteerMainFrameState();
}

class _VolunteerMainFrameState extends State<VolunteerMainFrame> {
  int _selectedIndex = 1;

  static const List<String> labels = [
    "Nasıl kullanılır?",
    "Ana Sayfa",
    "Ayarlar"
  ];

  static List<Widget> _widgetOptions = <Widget>[
    Text("Nasıl kullanılır?"),
    VolunteerHomeScreen("Furkan", DateTime.parse("2023-12-04"), [
      "Aşçılık",
      "Psikoloji",
      "Botanik",
      "Bilgisayar",
      "Mühendislik",
    ]),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    String? phoneNumber =
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
            icon: Icon(Icons.question_mark),
            label: "Nasıl kullanılır?",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
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
