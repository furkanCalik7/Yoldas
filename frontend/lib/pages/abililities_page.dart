import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/custom_dropdown.dart';
import 'package:frontend/custom_widgets/custom_listView.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:http/http.dart' as http;

class AbilitiesPage extends StatefulWidget {
  const AbilitiesPage({super.key});

  @override
  State<AbilitiesPage> createState() => _AbilitiesPageState();
}

class _AbilitiesPageState extends State<AbilitiesPage> {
  List<String> possibleAbilities = [
    'Sağlık',
    'Müzik',
    'Aşçılık',
    'Alışveriş',
    'Hukuk',
    'Felsefe',
    'Eğitim',
    'Ekonomi',
    'Psikoloji',
    'Botanik'
  ];

  List<String> userAbilities = [];
  String phoneNumber = "";
  String bearerToken = "";

  String? selectedAbility; // Changed to nullable

  void readUserInfo() async {
    bearerToken =
        SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
            await SecureStorageManager.read(key: StorageKey.access_token) ??
            "";
    userAbilities =
        SecureStorageManager.readListFromCache(key: StorageKey.abilities) ??
            await SecureStorageManager.readList(key: StorageKey.abilities) ??
            [];
    phoneNumber =
        SecureStorageManager.readFromCache(key: StorageKey.phone_number) ??
            await SecureStorageManager.read(key: StorageKey.phone_number) ??
            "";
    setState(() {});
  }

  @override
  void initState() {
    readUserInfo();
    // getAllAbilities();
    super.initState();
  }
  //
  // void getAllAbilities() async {
  //   String path = '/users/get_all_abilities';
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json;charset=UTF-8',
  //   };
  //
  //   http.Response response = await ApiManager.get(
  //     path,
  //     headers,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // Manually decode the response body using UTF-8 encoding
  //     Map<String, dynamic> responseBody =
  //         jsonDecode(utf8.decode(response.bodyBytes));
  //     setState(() {
  //       possibleAbilities = List.from(responseBody.values.toList());
  //     });
  //   } else {
  //     print('ERROR: Status code: ${response.statusCode}');
  //   }
  // }

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
          content: Text('Yetenekleriniz başarıyla güncellendi.'),
        ),
      );
    } else {
      print('ERROR: Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yetenekleriniz güncellenirken bir hata oluştu.'),
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
        padding: EdgeInsets.all(30),
        decoration: getBackgroundDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomDropdown(
              items: possibleAbilities,
              onChanged: selectAbility,
              selectedValue: selectedAbility,
              hintText: 'Bir Yetenek Seçin',
            ),
            SizedBox(height: 20),
            ButtonMain(
              action: () {
                addAbility();
                updateUserAbilities();
              },
              text: "Ekle",
            ),
            SizedBox(height: 50),
            Expanded(
              child: CustomListView(
                list: userAbilities,
                onDelete: (int index) {
                  removeAbility(index);
                  updateUserAbilities();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
