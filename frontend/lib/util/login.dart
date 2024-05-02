import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';

import '../controller/webrtc/dto/call_accept.dart';
import '../controller/webrtc/dto/call_accept_response.dart';
import '../main.dart';
import '../pages/call_main_frame.dart';

class CallingKitService {
  static final CallingKitService _instance = CallingKitService._internal();

  factory CallingKitService() {
    return _instance;
  }

  CallingKitService._internal() {
    MethodChannel('YOUR_CHANNEL_NAME').setMethodCallHandler(
      (call) async {
        if (call.method == 'CALL_ACCEPTED_INTENT') {
          final data = call.arguments;
          print("test callkit $data");
          if (data != null) {
            _completer.complete(data);
          } else {
            _completer.completeError('No data found');
          }
        }
      },
    );
  }

  final Completer<Map> _completer = Completer();

  Future<Map> getAppLaunchedData() async {
    try {
      Timer(const Duration(seconds: 2), () {
        if (!_completer.isCompleted) {
          _completer.complete({});
        }
      });
      return await _completer.future;
    } catch (e) {
      log('tset Either data is empty or No call received in killed state: ${e.toString()}');
      return {};
    }
  }
}

Future<CallAcceptResponse> handleCallAccept(String callId) async {
  String accessToken =
      await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

  CallReject callAccept = CallReject(
    callID: callId,
  );

  final response = await ApiManager.post(
    path: "/calls/call/accept",
    bearerToken: accessToken,
    body: callAccept.toJSON(),
  );

  return CallAcceptResponse.fromJson(jsonDecode(response.body));
}

class Login {
  // Login function
  static Future<void> tryLoginWithoutSMSVerification(
      BuildContext context) async {
    String phoneNumber;
    String password;

    print(SecureStorageManager.read(key: StorageKey.phone_number));

    phoneNumber =
        SecureStorageManager.readFromCache(key: StorageKey.phone_number) ??
            await SecureStorageManager.read(key: StorageKey.phone_number) ??
            "N/A";
    password = SecureStorageManager.readFromCache(key: StorageKey.password) ??
        await SecureStorageManager.read(key: StorageKey.password) ??
        "N/A";

    if (phoneNumber == "N/A" || password == "N/A") {
      print("No phone number or password found in storage");

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
      return;
    }

    var response = await ApiManager.post(
      path: "/users/login",
      body: {
        'username': phoneNumber,
        'password': password,
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
          key: StorageKey.password, value: password);

      await SecureStorageManager.writeList(
          key: StorageKey.abilities, value: user['abilities']);

      var extras = await CallingKitService().getAppLaunchedData();
      if (extras["callId"] != null) {
        var callId = extras["callId"];
        CallAcceptResponse response = await handleCallAccept(callId);
        if (response.isAccepted) {
          navigationKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => CallMainFrame(
                  callId: callId,
                  callActionType: "accept",
                ),
              ),
              ModalRoute.withName('/onboarding'));
        } else {
          // TODO: show it is already accepted thank you
        }
        return;
      }

      UserType userType =
          user['role'] == "volunteer" ? UserType.volunteer : UserType.blind;

      String mainFrameRootName = userType == UserType.volunteer
          ? VolunteerMainFrame.routeName
          : BlindMainFrame.routeName;

      // Rest of your code for successful response
      Navigator.pushNamedAndRemoveUntil(context, mainFrameRootName, (r) {
        return false;
      });
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
    }
  }
}
