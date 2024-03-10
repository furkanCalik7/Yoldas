import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:http/http.dart' as http;

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmNewPasswordController = TextEditingController();

  String _errorMessage = '';
  bool _passwordsMatch = false;
  String bearerToken = "";
  String currentPasswordInStorage = "";
  String phoneNumber = "";

  _getLocalStorageFields() async {
    bearerToken = await storage.read(key: "access_token") ?? "N/A";
    currentPasswordInStorage = await storage.read(key: "password") ?? "N/A";
    phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
  }

  @override
  void initState() {
    _getLocalStorageFields();
    super.initState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Şifreyi Değiştir",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                icon: Icons.lock_outline,
                obscureText: false,
                controller: _currentPasswordController,
                hintText: "Eski Şifre",
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                icon: Icons.lock,
                obscureText: false,
                controller: _newPasswordController,
                hintText: "Yeni Şifre",
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                icon: Icons.lock_reset_rounded,
                obscureText: false,
                controller: _confirmNewPasswordController,
                hintText: "Yeni Şifre Tekrar",
                validator: (value) {
                  return null;
                },
                onChanged: (value) => _checkPasswordsMatch(),
              ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              const Spacer(),
              ButtonMain(
                  text: "Şifreyi Güncelle",
                  action: () {
                    _changePassword();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _checkPasswordsMatch() {
    setState(() {
      if (_newPasswordController.text == _confirmNewPasswordController.text) {
        _errorMessage = '';
        _passwordsMatch = true;
      } else {
        _errorMessage = 'Passwords do not match';
        _passwordsMatch = false;
      }
    });
  }

  Future<void> _changePassword() async {
    // Implement your password change logic here
    if (_passwordsMatch &&
        _newPasswordController.text.isNotEmpty &&
        _currentPasswordController.text == currentPasswordInStorage) {
      await _getLocalStorageFields();

      Map<String, dynamic> userUpdateObj = HashMap();

      String newPassword = _newPasswordController.text;

      userUpdateObj["password"] = newPassword;

      String jsonBody = jsonEncode(userUpdateObj);

      String apiUrl = '$API_URL/users/update/$phoneNumber';

      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        await storage.write(key: "password", value: newPassword);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Şifre başarıyla değiştirildi'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Şifre değiştirilemedi'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Şifre değiştirilemedi'),
      ));
    }
  }
}
