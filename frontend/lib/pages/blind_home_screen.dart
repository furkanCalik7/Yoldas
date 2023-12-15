import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/category_selection_screen.dart';
class BlindHomeScreen extends StatelessWidget {
  const BlindHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            TappableIcon(
              action: () {
                print("tapped to 1");
              },
              iconData: Icons.search,
              size: 150,
              text: "Hızlı Arama",
            ),
            SizedBox(height: 50,),
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
