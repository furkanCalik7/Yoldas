import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_big.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/onboarding_screen.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});
  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    // Login.tryLoginWithoutSMSVerification(context);

    return Scaffold(
      body: Container(
        decoration: getBackgroundDecoration(),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.fromLTRB(0, 100, 0, 20),
                  child: const Icon(
                    Icons.blind,
                    size: 200.0,
                    color: tertiaryColor,
                  ),
                ),
                const TextHead(line: "YOLDAŞ"),
                const SizedBox(
                  height: 50.0,
                ),
                ButtonBig(
                    text: "Giriş yap",
                    action: () {
                      Navigator.pushNamed(context, LoginScreen.routeName);
                    }),
                SizedBox(
                  height: 20.0,
                ),
                ButtonBig(
                    text: "Kaydol",
                    action: () {
                      Navigator.pushNamed(context, OnboardingScreen.routeName);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
