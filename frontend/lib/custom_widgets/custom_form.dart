import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_phoneNumberInput.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/utility/auth_behavior.dart';
import 'package:frontend/utility/types.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_data.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomForm extends StatefulWidget {
  const CustomForm({Key? key, required this.userType}) : super(key: key);

  final UserType userType;
  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  UserType? userType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userType = widget.userType;
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'TR';
  // PhoneNumber number = PhoneNumber(isoCode: 'TR');

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber number = PhoneNumber(isoCode: 'TR');

  bool evaluateName(String name) {
    // TODO: implement evaluateName
    return false;
  }

  bool evaluatePassword(String password) {
    // TODO: implement evaluatePassword
    return false;
  }

  bool evaluateConfirmPassword(String confirmPassword) {
    // TODO: implement evaluateConfirmPassword
    return false;
  }

  bool evaluatePhoneNumber(String phoneNumber) {
    // TODO: implement evaluatePhoneNumber
    return false;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  UserData createUser(String phoneNumber) {
    String name = nameController.text;
    String password = passwordController.text;

    return UserData(name: name, password: password, phoneNumber: phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    CustomPhoneNumberInput customPhoneNumberInput = CustomPhoneNumberInput(
        controller: phoneNumberController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen telefon numaranızı giriniz';
          }
          return null;
        });

    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: formColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextFormField(
              icon: Icons.person,
              hintText: "Ad Soyad",
              obscureText: false,
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen adınızı giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            customPhoneNumberInput,
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: Icons.lock,
              hintText: "Şifre",
              obscureText: true,
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen şifrenizi giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              icon: Icons.repeat_on_rounded,
              hintText: "Şifre Tekrar",
              obscureText: true,
              controller: confirmPasswordController,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value != passwordController.text) {
                  return 'Şifreler uyuşmuyor';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ButtonMain(
              action: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.

                  UserData user =
                      createUser(customPhoneNumberInput.getPhoneNumber());

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => SMSCodePage(
                            userType: userType!,
                            user: user,
                            phoneNumber:
                                customPhoneNumberInput.getPhoneNumber(),
                            authBehavior: AuthenticationBehavior.Register,
                          )));
                }
              },
              text: 'Submit',
            )
          ],
        ),
      ),
    );
  }
}
