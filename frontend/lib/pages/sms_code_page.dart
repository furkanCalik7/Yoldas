import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/custom_widgets/appbars/appbar_default.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/auth_behavior.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:vibration/vibration.dart';

import '../config.dart';
import '../firebase_options.dart';
import '../models/user_data.dart';

class SMSCodePage extends StatefulWidget {
  static const String routeName = "/pin_code_verification_screen";

  const SMSCodePage(
      {Key? key,
      this.phoneNumber = "+905555555555",
      required this.userType,
      required this.user,
      required this.authBehavior})
      : super(key: key);

  final String? phoneNumber;
  final UserType userType;
  final UserData user;
  final AuthenticationBehavior authBehavior;

  @override
  State<SMSCodePage> createState() => _SMSCodePageState();
}

class _SMSCodePageState extends State<SMSCodePage> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  UserType? userType;
  late FirebaseAuth _auth;
  var verificationIdx = ''.obs;
  bool isSMSCodeSent = false;

  @override
  void initState() {
    userType = widget.userType;
    errorController = StreamController<ErrorAnimationType>();
    sendSMS(widget.user.phoneNumber);
    super.initState();
    if (userType == UserType.blind) {
      flutterTTs.speak("SMS ile gelen kodu giriniz");
    }
    SmsAutoFill().listenForCode;
    // Listen for SMS code changes
    SmsAutoFill().code.listen((code) {
      // Handle the retrieved code according to your application logic
      handleSMSCode(code);
    });
  }

  void handleSMSCode(String? code) {
    // Implement your logic to handle the retrieved SMS code
    print("Filling the code received via SMS");
    if (code != null) {
      print("Received code: $code");
      // Do something with the SMS code, such as validating it or filling it in a field
      setState(() {
        textEditingController.text = code; // Example: Fill the code in a text field
      });
    }
  }


  @override
  void dispose() {
    errorController!.close();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void sendSMS(String phoneNumber) async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) async {
        verificationIdx.value = verificationId;
        setState(() {
          isSMSCodeSent = true;
        });
      },
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: (verificationId) {
        verificationIdx.value = verificationId;
      },
    );
  }

  Future<int> register() async {
    String name = widget.user.name;
    String password = widget.user.password;
    String phoneNumber = widget.user.phoneNumber;

    String path = API_URL + "/users/register";

    Map<String, dynamic> requestBody = {
      "name": name,
      "role": userTypeToString(userType!),
      "phone_number": phoneNumber,
      "password": password,
    };

    final response = await ApiManager.post(
      path: "/users/register",
      body: requestBody,
    );

    Map data = jsonDecode(response.body);

    String hashedPassword = data["user"]["password"];

    if (response.statusCode == 200) {
      await SecureStorageManager.write(key: StorageKey.name, value: name);
      await SecureStorageManager.write(
          key: StorageKey.password, value: password);
      await SecureStorageManager.write(
          key: StorageKey.phone_number, value: phoneNumber);
      await SecureStorageManager.write(
          key: StorageKey.role, value: userTypeToString(userType!));
      await SecureStorageManager.write(key: StorageKey.is_active, value: "true");
    }

    return response.statusCode;
  }

  Future<int> checkAuthentication(RxString verificationId) async {
    String smsCode = currentText;

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value, smsCode: smsCode);

    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print(userCredential);
      if (widget.authBehavior == AuthenticationBehavior.Register) {
        return await register();
      } else {
        await SecureStorageManager.write(
            key: StorageKey.access_token, value: widget.user.accessToken);
        await SecureStorageManager.write(
            key: StorageKey.token_type, value: widget.user.tokenType);
        await SecureStorageManager.write(
            key: StorageKey.name, value: widget.user.name);
        await SecureStorageManager.write(
            key: StorageKey.role, value: widget.user.role);
        await SecureStorageManager.write(
            key: StorageKey.phone_number, value: widget.user.phoneNumber);
        await SecureStorageManager.write(
            key: StorageKey.password, value: widget.user.password);
        await SecureStorageManager.write(
            key: StorageKey.isConsultant, value: widget.user.isConsultant.toString());
        await SecureStorageManager.write(
            key: StorageKey.is_active, value: widget.user.isActive.toString());

        await SecureStorageManager.write(key: StorageKey.call_count, value: widget.user.callCount.toString());

        await SecureStorageManager.writeList(
            key: StorageKey.abilities, value: widget.user.abilities);

        return 200;
      }
    } catch (e) {
      errorController!
          .add(ErrorAnimationType.shake); // Triggering error shake animation
      Vibration.vibrate();
      setState(() => hasError = true);
      snackBar("Kod doğrulama başarısız");
      return -1;
    }
  }

  void navigateUser() async {
    formKey.currentState!.validate();
    if (currentText.length != 6) {
      errorController!
          .add(ErrorAnimationType.shake);
      Vibration.vibrate();
      setState(() => hasError = true);
    } else {
      setState(
        () {
          hasError = false;
        },
      );
      int statusCode = await checkAuthentication(verificationIdx);

      if (statusCode == -1) {
        return;
      } else if (statusCode == 200) {
        snackBar("Doğrulama Başarılı");
        if (userType == UserType.blind) {
          Navigator.pushNamedAndRemoveUntil(context, BlindMainFrame.routeName,
              (r) {
            return false;
          });
        } else if (userType == UserType.volunteer) {
          Navigator.pushNamedAndRemoveUntil(
              context, VolunteerMainFrame.routeName, (r) {
            return false;
          });
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, SMSCodePage.routeName, (r) {
          return false;
        });
        return;
      }
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    RegExp pattern = RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{2})(\d{2})$');

    RegExpMatch? match = pattern.firstMatch(digitsOnly);

    if (match != null) {
      return '+${match[1]} ${match[2]} ${match[3]} ${match[4]} ${match[5]}';
    } else {
      return phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarDefault(),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                const TextContainer(text: "SMS Kontrol"),
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8),
                        child: Text(
                          "${formatPhoneNumber(widget.phoneNumber!)} a gelen doğrulama kodunu giriniz",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: textColorLight,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 50,
                        ),

                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "Lütfen tüm haneleri doldurun";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(0),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: textColorLight,
                            inactiveFillColor: textColorLight.withOpacity(0.8),
                          ),
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,

                          onCompleted: (v) {
                            debugPrint("Completed");
                          },
                          onChanged: (value) {
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            return true;
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        hasError
                            ? "*Lütfen tüm haneleri doğru bir şekilde doldurun"
                            : "",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Kodu almadınız mı? ",
                          style: TextStyle(color: textColorLight, fontSize: 20),
                        ),
                        TextButton(
                          onPressed: () {
                            sendSMS(widget.user.phoneNumber);
                            snackBar("SMS Tekrar Gönderildi");
                          },
                          child: const Text(
                            "Tekrar Gönder",
                            style: TextStyle(
                              color: Color(0xFF91D3B3),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonMain(
                        text: "Dogrula",
                        action: isSMSCodeSent ? navigateUser : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
