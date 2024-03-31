import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_form.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container.dart';
import 'package:frontend/util/types.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.userType});

  static const String routeName = "/register";

  final UserType userType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarDefault(),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const TextContainer(text: "Kayıt Ol"),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: CustomForm(
                    userType: userType,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
