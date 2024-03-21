import 'package:frontend/config.dart';
import 'package:frontend/controller/socket_controller.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utility/types.dart';
import 'package:frontend/utility/secure_storage.dart';
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

    phoneNumber =
        await SecureStorageManager.read(key: StorageKey.phone_number) ?? "N/A";
    password =
        await SecureStorageManager.read(key: StorageKey.password) ?? "N/A";

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
          key: StorageKey.email, value: user['email']);
      await SecureStorageManager.write(
          key: StorageKey.password, value: password);

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
