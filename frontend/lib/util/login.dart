import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';

class Login {
  // Login function
  static Future<void> tryLoginWithoutSMSVerification(
      BuildContext context) async {
    // for test purposes
    // TODO: remove please
    await Future.delayed(Duration(seconds: 1));

    // String path = "$API_URL/users/login";
    String phoneNumber;
    String password;

    print(SecureStorageManager.read(key: StorageKey.phone_number));

    phoneNumber = SecureStorageManager.readFromCache(key: StorageKey.phone_number) ??
        await SecureStorageManager.read(key: StorageKey.phone_number) ?? "N/A";
    password = SecureStorageManager.readFromCache(key: StorageKey.password) ??
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
      await SecureStorageManager.write(
          key: StorageKey.is_active, value: user['is_active'].toString());

      await SecureStorageManager.writeList(
          key: StorageKey.abilities, value: user['abilities']);

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
