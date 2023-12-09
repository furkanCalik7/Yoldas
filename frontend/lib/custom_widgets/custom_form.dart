import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/custom_phoneNumberInput.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/pages/sms_code_page.dart';
import 'package:frontend/utility/types.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;

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
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  PhoneNumber number = PhoneNumber(isoCode: 'TR');

  bool evaluateName(String name) {
    // TODO: implement evaluateName
    return false;
  }

  bool evaluateMail(String mail) {
    // TODO: implement evaluateMail
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
    mailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void register() async {

    String name_and_surname = nameController.text;
    String name = name_and_surname.split(" ")[0];
    String surname = name_and_surname.split(" ")[1];
    String mail = mailController.text;
    String password = passwordController.text;
    String phoneNumber = phoneNumberController.text;
    Future response =  http.post(Uri.parse('http://127.0.0.1:8000/users/register'), body: {
      'first_name': name,
      'last_name': surname,
      'mail': mail,
      'password': password,
      'phone_number': phoneNumber,
    });


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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
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
            CustomTextFormField(
              icon: Icons.mail,
              hintText: "E-posta",
              obscureText: false,
              controller: mailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen e-posta adresinizi giriniz';
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
              action: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gönderiliyor...')),
                  );
                  print(customPhoneNumberInput.getPhoneNumber());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PinCodeVerificationScreen(
                            userType: userType!,
                            phoneNumber:
                                customPhoneNumberInput.getPhoneNumber(),
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
