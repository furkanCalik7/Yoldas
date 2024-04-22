import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_switch.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  // final FlutterSecureStorage storage = const FlutterSecureStorage();
  // final SecureStorageManager storageManager = SecureStorageManager();

  String current_name = "";
  String current_phoneNumber = "";
  String current_password = "";
  UserType? current_userType;
  bool consultancy_status = false;

  String bearerToken = "";

  bool somethingChanged = false;

  final newNameController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPhoneNumberController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future _getFieldsFromStorage() async {
    current_name = SecureStorageManager.readFromCache(key: StorageKey.name) ??
        await SecureStorageManager.read(key: StorageKey.name) ?? "N/A";
    current_phoneNumber = SecureStorageManager.readFromCache(key: StorageKey.phone_number) ??
        await SecureStorageManager.read(key: StorageKey.phone_number) ?? "N/A";
    current_password = SecureStorageManager.readFromCache(key: StorageKey.password) ??
        await SecureStorageManager.read(key: StorageKey.password) ?? "N/A";
    bearerToken = SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";
    consultancy_status = SecureStorageManager.readFromCache(key: StorageKey.isConsultant) == "true" ||
        await SecureStorageManager.read(key: StorageKey.isConsultant) == "true";
    current_userType = stringToUserType( SecureStorageManager.readFromCache(key: StorageKey.role) ??
        await SecureStorageManager.read(key: StorageKey.role) ?? "N/A");

    setState(() {});
  }

  @override
  void initState() {
    _getFieldsFromStorage();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    newNameController.dispose();
    newPasswordController.dispose();
    newPhoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    print("Current phone number: $current_phoneNumber");

    String newPassword = newPasswordController.text;
    String newName = newNameController.text;

    Map<String, dynamic> userUpdateObj = HashMap();

    if (newName != "" && newName != current_name) {
      userUpdateObj["name"] = newName;
      somethingChanged = true;
    }

    if (newPassword != "" && newPassword != current_password) {
      userUpdateObj["password"] = newPassword;
      somethingChanged = true;
    }

    userUpdateObj["isConsultant"] = consultancy_status;

    if (somethingChanged == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiçbir alan güncellenmedi'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    String jsonBody = jsonEncode(userUpdateObj);

    String apiUrl = '$API_URL/users/update/$current_phoneNumber';

    var response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonBody,
    );

    // Check the response status
    if (response.statusCode == 200) {
      print('PUT request successful');
      print('Response body: ${response.body}');

      if (newName != "") {
        await SecureStorageManager.write(key: StorageKey.name, value: newName);
      }

      await SecureStorageManager.write(
          key: StorageKey.isConsultant, value: consultancy_status.toString());

      if (newPassword != "") {
        await SecureStorageManager.write(
            key: StorageKey.password, value: newPassword);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
        ),
      );

      await _getFieldsFromStorage();
    } else {
      print('PUT request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil güncellenirken bir hata oluştu'),
        ),
      );
      Navigator.pop(context);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    newNameController.text = current_name;
    newPasswordController.text = current_password;
    newPhoneNumberController.text = current_phoneNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Güncellemek istediğiniz alanları doldurunuz",
            style: TextStyle(
              fontSize: 15,
              color: textColorLight,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            icon: Icons.person,
            obscureText: false,
            controller: newNameController,
            validator: (value) {
              return null;
            },
            hintText: "Ad Soyad",
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            icon: Icons.phone,
            obscureText: false,
            enabled: false,
            controller: newPhoneNumberController,
            validator: (value) {
              return null;
            },
            hintText: "Telefon Numarası",
          ),
          const SizedBox(height: 20),
          if (current_userType == UserType.blind)
            Row(
              children: [
                const Text(
                  "Danışmanlık Durumu:",
                  style: TextStyle(
                    fontSize: 15,
                    color: textColorLight,
                  ),
                ),
                const SizedBox(width: 20),
                CustomSwitch(
                  value: consultancy_status,
                  onChanged: (newValue) {
                    setState(() {
                      consultancy_status = newValue;
                    });
                    somethingChanged = true;
                  },
                ),
              ],
            ),
          const Spacer(),
          ButtonMain(
              text: "Profili Güncelle",
              action: () {
                _updateProfile();
              }),
        ],
      ),
    );
  }
}
