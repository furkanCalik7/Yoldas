import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/blind_home_screen.dart';
import 'package:frontend/pages/settings_screen.dart';
import 'package:frontend/pages/volunteer_home_screen.dart';

import '../custom_widgets/appbars/appbar_custom.dart';
import 'ai_model_selection_page.dart';
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
    VolunteerHomeScreen("Furkan", DateTime.parse("2023-12-04"), ["Aşçılık", "Psikoloji", "Botanik", "Bilgisayar", "Mühendislik", "Tarih", "Felsefe", "Biyoloji", "Kimya", "Fizik", "Matematik", "Edebiyat", "Müzik", "Sanat", "Spor", "Tiyatro", "Sinema", "Dans", "Fotoğrafçılık", "Yazılım", "Mobil", "Web", "Oyun", "Masaüstü", "Mühendislik", "Tarih", "Felsefe", "Biyoloji", "Kimya", "Fizik", "Matematik", "Edebiyat", "Müzik", "Sanat", "Spor", "Tiyatro", "Sinema", "Dans", "Fotoğrafçılık", "Yazılım", "Mobil", "Web", "Oyun", "Masaüstü", "Mühendislik", "Tarih", "Felsefe", "Biyoloji", "Kimya", "Fizik", "Matematik", "Edebiyat", "Müzik", "Sanat", "Spor", "Tiyatro", "Sinema", "Dans", "Fotoğrafçılık", "Yazılım", "Mobil", "Web", "Oyun", "Masaüstü", "Mühendislik", "Tarih", "Felsefe", "Biyoloji", "Kimya", "Fizik", "Matematik", "Edebiyat", "Müzik", "Sanat", "Spor", "Tiyatro", "Sinema",]),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBackgroundColor,
      appBar: AppbarCustom(title: labels[_selectedIndex],),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
