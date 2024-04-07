import 'package:flutter/material.dart';
import 'package:frontend/controller/webrtc/web_rtc_controller.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';

class BlindHomeScreen extends StatelessWidget {
  WebRTCController webRTCController = WebRTCController();
  BlindHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          TappableIcon(
            action: () {
              Navigator.pushNamed(context, VolunteerSearchScreen.routeName);
            },
            iconData: Icons.search,
            size: 150,
            text: "Hızlı Arama",
          ),
          const SizedBox(
            height: 50,
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
