import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBackgroundColor,
      body: Center(
        child: SafeArea(
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TextHead(line: "YOLDAS"),
                const SizedBox(
                  height: 80,
                ),
                TappableIcon(
                    action: () {
                      print("tapped to 1");
                    },
                    iconData: Icons.blind,
                    size: 150,
                    text: "Görme Engelliyim"),
                const SizedBox(
                  height: 60,
                ),
                TappableIcon(
                  action: () {
                    print("tapped to 2");
                  },
                  iconData: Icons.volunteer_activism,
                  size: 150,
                  text: "Gönüllüyüm",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
