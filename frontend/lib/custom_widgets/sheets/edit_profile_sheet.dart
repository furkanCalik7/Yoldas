import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utility/secure_storage.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  // final FlutterSecureStorage storage = const FlutterSecureStorage();
  // final SecureStorageManager storageManager = SecureStorageManager();

  String current_name = "";
  String current_email = "";
  String current_phoneNumber = "";
  String current_password = "";

  String bearerToken = "";

  final newNameController = TextEditingController();
  final newMailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPhoneNumberController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future _getFieldsFromStorage() async {
    // current_name = await storage.read(key: "name") ?? "N/A";
    // current_email = await storage.read(key: "email") ?? "N/A";
    // current_phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
    // current_password = await storage.read(key: "password") ?? "N/A";
    // bearerToken = await storage.read(key: "access_token") ?? "N/A";

    current_name =
        await SecureStorageManager.read(key: StorageKey.name) ?? "N/A";
    current_email =
        await SecureStorageManager.read(key: StorageKey.email) ?? "N/A";
    current_phoneNumber =
        await SecureStorageManager.read(key: StorageKey.phone_number) ?? "N/A";
    current_password =
        await SecureStorageManager.read(key: StorageKey.password) ?? "N/A";
    bearerToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

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
    newMailController.dispose();
    newPasswordController.dispose();
    newPhoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    await _getFieldsFromStorage();

    print("Current phone number: $current_phoneNumber");

    String newPassword = newPasswordController.text;
    String newMail = newMailController.text;
    String newName = newNameController.text;

    bool somethingChanged = false;

    Map<String, dynamic> userUpdateObj = HashMap();

    if (newName != "" && newName != current_name) {
      userUpdateObj["name"] = newName;
      somethingChanged = true;
    }

    if (newMail != "" && newMail != current_email) {
      userUpdateObj["mail"] = newMail;
      somethingChanged = true;
    }

    if (newPassword != "" && newPassword != current_password) {
      userUpdateObj["password"] = newPassword;
      somethingChanged = true;
    }

    if (somethingChanged == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiçbir alan güncellenmedi'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    // TODO : Currently it doesnt update email in database, fix it when backend is updated
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

      //TODO: Update the local storage with the correct key names when the backend is updated
      // if (newName != "") await storage.write(key: "name", value: newName);
      // if (newMail != "") await storage.write(key: "email", value: newMail);
      // if (newPassword != "")
      //   await storage.write(key: "password", value: newPassword);

      if (newName != "") {
        await SecureStorageManager.write(key: StorageKey.name, value: newName);
      }
      if (newMail != "") {
        await SecureStorageManager.write(key: StorageKey.email, value: newMail);
      }
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
    newMailController.text = current_email;
    newPasswordController.text = current_password;
    newPhoneNumberController.text = current_phoneNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Güncellemek istediğiniz alanları doldurunuz",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            icon: Icons.person,
            obscureText: false,
            controller: newNameController,
            validator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            icon: Icons.mail,
            obscureText: false,
            enabled: false,
            controller: newMailController,
            validator: (value) {
              return null;
            },
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
