import 'package:frontend/config.dart';
import 'package:frontend/controller/socket_controller.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utility/types.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Login {
  // Login function
  static Future<void> tryLoginWithoutSMSVerification(
      BuildContext context) async {
    // for test purposes
    await Future.delayed(Duration(seconds: 1));

    String path = "$API_URL/users/login";
    String phoneNumber;
    String password;

    FlutterSecureStorage storage = const FlutterSecureStorage();

    phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
    password = await storage.read(key: "password") ?? "N/A";

    if (phoneNumber == "N/A" || password == "N/A") {
      print("No phone number or password found in storage");

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
      return;
    }

    var response = await http.post(
      Uri.parse(path),
      body: {
        'grant_type': '',
        'username': phoneNumber,
        'password': password,
        'scope': '',
        'client_id': '',
        'client_secret': '',
      },
      headers: {'content-type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      Map user = data['user'];

      // local storage writing
      FlutterSecureStorage storage = const FlutterSecureStorage();

      storage.write(key: "access_token", value: data['access_token']);
      storage.write(key: "token_type", value: data['token_type']);
      storage.write(key: "name", value: user['name']);
      storage.write(key: "role", value: user['role']);
      storage.write(key: "phone_number", value: user['phone_number']);
      storage.write(key: "email", value: user['email']);
      storage.write(key: "password", value: password);

      SocketController socketController = SocketController.instance;
      await socketController.connect();
      IO.Socket socket = await socketController.connect();

      UserType userType =
          user['role'] == "volunteer" ? UserType.volunteer : UserType.blind;

      String mainFrameRootName = userType == UserType.volunteer
          ? VolunteerMainFrame.routeName
          : BlindMainFrame.routeName;

      // Rest of your code for successful response
      Navigator.pushNamedAndRemoveUntil(context, mainFrameRootName, (r) {
        return false;
      }); 
      // TODO: Bu senaryo bana cok sacma geldi, bır daha bak
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
