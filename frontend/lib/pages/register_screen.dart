import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_form.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container.dart';
import 'package:frontend/utility/types.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, required this.userType});

  final UserType userType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBackgroundColor,
      appBar: const AppbarDefault(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const TextContainer(text: "Kayıt Ol"),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.all(20),
                child: const CustomForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
