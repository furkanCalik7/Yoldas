import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/register_screen.dart';
import 'package:frontend/utility/types.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String routeName = "/onboarding";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Column(
          children: [
            const AppbarDefault(),
            Center(
              child: SafeArea(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      TappableIcon(
                          action: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => const RegisterScreen(
                                      userType: UserType.blind,
                                    )));
                          },
                          iconData: Icons.blind,
                          size: 140,
                          text: "Görme Engelliyim"),
                      const SizedBox(
                        height: 60,
                      ),
                      TappableIcon(
                        action: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const RegisterScreen(
                                    userType: UserType.volunteer,
                                  )));
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
          ],
        ),
      ),
    );
  }
}
