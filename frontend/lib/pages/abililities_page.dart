import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_dropdown.dart';
import 'package:frontend/custom_widgets/custom_listView.dart';
import 'package:frontend/utility/secure_storage_manager.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utility/api_manager.dart';

class AbilitiesPage extends StatefulWidget {
  const AbilitiesPage({super.key});

  @override
  State<AbilitiesPage> createState() => _AbilitiesPageState();
}

class _AbilitiesPageState extends State<AbilitiesPage> {
  List<String> possibleAbilities = [];

  List<String> userAbilities = [];
  String phoneNumber = "";
  String bearerToken = "";

  String? selectedAbility; // Changed to nullable

  void readUserInfo() async {
    bearerToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "";
    userAbilities =
        await SecureStorageManager.readList(key: StorageKey.abilities) ?? [];
    phoneNumber =
        await SecureStorageManager.read(key: StorageKey.phone_number) ?? "";
    setState(() {});
  }

  @override
  void initState() {
    readUserInfo();
    getAllAbilities();
    super.initState();
  }

  void getAllAbilities() async {
    String path = '/users/get_all_abilities}';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
    };

    http.Response response = await ApiManager.get(
      path,
      headers,
    );

    if (response.statusCode == 200) {
      // Manually decode the response body using UTF-8 encoding
      Map<String, dynamic> responseBody =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        possibleAbilities = List.from(responseBody.values.toList());
      });
    } else {
      print('ERROR: Status code: ${response.statusCode}');
    }
  }

  void selectAbility(String? ability) {
    setState(() {
      selectedAbility = ability;
    });
  }

  void addAbility() {
    if (selectedAbility != null &&
        selectedAbility!.isNotEmpty &&
        !userAbilities.contains(selectedAbility)) {
      setState(() {
        userAbilities.add(selectedAbility!);
        selectedAbility = null; // Reset selectedSkill
      });
    }
  }

  void removeAbility(int index) {
    setState(() {
      userAbilities.removeAt(index);
    });
  }

  void updateUserAbilities() async {
    String path = '/users/update/$phoneNumber';

    http.Response response = await ApiManager.put(
      path: path,
      bearerToken: bearerToken,
      body: {
        'abilities': userAbilities,
      },
    );

    if (response.statusCode == 200) {
      // Save the updated abilities to secure storage
      await SecureStorageManager.writeList(
        key: StorageKey.abilities,
        value: userAbilities,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User abilities updated successfully'),
        ),
      );
    } else {
      print('ERROR: Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user abilities'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: 'Yeteneklerim',
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: getBackgroundDecoration(),
        child: Column(
          children: [
            CustomDropdown(
              items: possibleAbilities,
              onChanged: selectAbility,
              selectedValue: selectedAbility,
              hintText: 'Bir Yetenek Seçin',
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonMain(
                  action: addAbility,
                  text: "Ekle",
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                ButtonMain(
                  action: updateUserAbilities,
                  text: "Kaydet",
                  width: MediaQuery.of(context).size.width * 0.4,
                  buttonColor: Colors.amber,
                ),
              ],
            ),
            SizedBox(height: 50),
            Expanded(
              child: CustomListView(
                list: userAbilities,
                onDelete: removeAbility,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
