import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/settings_screen.dart';

import '../custom_widgets/appbars/appbar_custom.dart';
import 'ai_model_selection_page.dart';

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
    const BlindHomeScreen(),
    const SettingsScreen(),
  ];
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
        backgroundColor: defaultButtonColor,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
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
