import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/pages/call_main_frame.dart';
import 'package:frontend/pages/category_selection_screen.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';

class BlindHomeScreen extends StatelessWidget {
  const BlindHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TappableIcon(
            action: () {
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
