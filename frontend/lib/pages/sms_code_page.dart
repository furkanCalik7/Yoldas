import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  UserType? userType;
  late FirebaseAuth _auth;
  var verificationIdx = ''.obs;

  @override
  void initState() {
    userType = widget.userType;
    errorController = StreamController<ErrorAnimationType>();
    sendSMS(widget.user.phoneNumber);
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
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
        print("successfully sent");
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
    }

    return response.statusCode;
  }

  Future<int> checkAuthentication(RxString verificationId) async {
    String smsCode = currentText;

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value, smsCode: smsCode);

    log("Credential created");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppbarDefault(),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  const TextContainer(text: "SMS Kontrol"),
                  Container(
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 8),
                            child: Text(
                              "${widget.phoneNumber} a gelen doğrulama kodunu giriniz",
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
                                inactiveFillColor:
                                    textColorLight.withOpacity(0.8),
                              ),
                              cursorColor: Colors.black,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,

                              onCompleted: (v) {
                                debugPrint("Completed");
                              },
                              // onTap: () {
                              //   print("Pressed");
                              // },
                              onChanged: (value) {
                                debugPrint(value);
                                setState(() {
                                  currentText = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                debugPrint("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
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
                              style: TextStyle(
                                  color: textColorLight, fontSize: 20),
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
                            action: () async {
                              formKey.currentState!.validate();
                              // conditions for validating
                              if (currentText.length != 6) {
                                errorController!.add(ErrorAnimationType
                                    .shake); // Triggering error shake animation
                                Vibration.vibrate();
                                setState(() => hasError = true);
                              } else {
                                setState(
                                  () {
                                    hasError = false;
                                  },
                                );
                                int statusCode =
                                    await checkAuthentication(verificationIdx);

                                if (statusCode == -1) {
                                  return;
                                } else if (statusCode == 200) {
                                  snackBar("Doğrulama Başarılı");
                                  if (userType == UserType.blind) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, BlindMainFrame.routeName, (r) {
                                      return false;
                                    });
                                  } else if (userType == UserType.volunteer) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, VolunteerMainFrame.routeName,
                                        (r) {
                                      return false;
                                    });
                                  }
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, SMSCodePage.routeName, (r) {
                                    return false;
                                  });
                                  return;
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
