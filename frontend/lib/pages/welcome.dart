import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_big.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/pages/login_with_phone.dart';
import 'package:frontend/pages/onboarding_screen.dart';
import 'package:frontend/util/login.dart';

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
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.fromLTRB(0, 100, 0, 30),
                child: Icon(
                  Icons.blind,
                  size: 200.0,
                ),
              ),
              Center(
                child: TextHead(line: "YOLDAS"),
              ),
              ButtonBig(
                  text: "Giris Yap",
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
    );
  }
}
