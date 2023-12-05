import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'TR';
  PhoneNumber number = PhoneNumber(isoCode: 'TR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: customBackgroundColor,
      appBar: AppbarDefault(),
      body: Column(
        children: [
          TextContainer(text: "Giris Yap"),
          Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)
              ),
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
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(color: Colors.black),
                        initialValue: number,
                        textFieldController: controller,
                        formatInput: true,
                        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                        inputBorder: OutlineInputBorder(),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20,),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Şifre",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Şifre',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30,),
                  ButtonMain(text: "Giriş Yap", action: () {
                    Navigator.pushReplacementNamed(context, "/verification");
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
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
    await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
