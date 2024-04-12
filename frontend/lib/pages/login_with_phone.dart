import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/auth_behavior.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../custom_widgets/custom_phoneNumberInput.dart';
import '../models/user_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static const String routeName = "/login";
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController phone_controller = TextEditingController();
  final password_controller = TextEditingController();
  String initialCountry = 'TR';
  PhoneNumber number = PhoneNumber(isoCode: 'TR');

  Future _login(String phoneNumber) async {
    String path = "$API_URL/users/login";

    var response = await ApiManager.post(
      path: "/users/login",
      body: {
        'grant_type': '',
        'username': phoneNumber,
        'password': password_controller.text,
        'scope': '',
        'client_id': '',
        'client_secret': '',
      },
      contentType: 'application/x-www-form-urlencoded',
    );

    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      Map user = data['user'];

      await SecureStorageManager.write(
          key: StorageKey.access_token, value: data['access_token']);
      await SecureStorageManager.write(
          key: StorageKey.token_type, value: data['token_type']);
      await SecureStorageManager.write(
          key: StorageKey.name, value: user['name']);
      await SecureStorageManager.write(
          key: StorageKey.role, value: user['role']);
      await SecureStorageManager.write(
          key: StorageKey.phone_number, value: user['phone_number']);
      await SecureStorageManager.write(
          key: StorageKey.password, value: password_controller.text);
      await SecureStorageManager.writeList(
          key: StorageKey.abilities, value: user['abilities']);

      String phoneNumber = user['phone_number'];
      UserType userType =
          user['role'] == "volunteer" ? UserType.volunteer : UserType.blind;

      UserData userData = UserData(
        phoneNumber: user['phone_number'],
        password: password_controller.text,
      );

      // Rest of your code for successful response
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SMSCodePage(
            userType: userType,
            user: userData,
            phoneNumber: phoneNumber,
            authBehavior: AuthenticationBehavior.Login,
          ),
        ),
      );
    } else {
      // Print the response body in case of an error
      print("Error: ${response.body}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı adı veya şifre hatalı"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomPhoneNumberInput customPhoneNumberInput = CustomPhoneNumberInput(
        controller: phone_controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen telefon numaranızı giriniz';
          }
          return null;
        });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppbarDefault(),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: getBackgroundDecoration(),
        child: Column(
          children: [
            const TextContainer(text: "Giris Yap"),
            Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: formColor, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Telefon Numarası",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        customPhoneNumberInput,
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Şifre",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        CustomTextFormField(
                          icon: Icons.lock,
                          hintText: "Şifre",
                          obscureText: true,
                          controller: password_controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi giriniz';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    ButtonMain(
                        text: "Giriş Yap",
                        action: () {
                          String phoneNumber =
                              customPhoneNumberInput.getPhoneNumber();
                          _login(phoneNumber);
                        })

                    // ElevatedButton(
                    //   onPressed: () {
                    //     formKey.currentState?.validate();
                    //   },
                    //   child: Text('Validate'),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     getPhoneNumber('+15417543010');
                    //   },
                    //   child: Text('Update'),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     formKey.currentState?.save();
                    //   },
                    //   child: Text('Save'),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    phone_controller.dispose();
    password_controller.dispose();
    super.dispose();
  }
}
