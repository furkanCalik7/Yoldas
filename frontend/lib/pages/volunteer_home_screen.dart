import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/abililities_page.dart';

import '../custom_widgets/text_widgets/text_container.dart';
import '../util/secure_storage.dart';

class VolunteerHomeScreen extends StatefulWidget {

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {

  String username = "";
  List<String> categories = [];
  String phoneNumber = "";

  getUserInfo() async{

    username = await SecureStorageManager.read(key: StorageKey.name) ?? "";
    categories = await SecureStorageManager.readList(key: StorageKey.abilities) ?? [];
    phoneNumber = await SecureStorageManager.read(key: StorageKey.phone_number) ?? "";

    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset("assets/home_image.png",),
          Container(
            height: 100,
            width: 300,
            decoration: BoxDecoration(
              color: textContainerColor, borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Merhaba $username",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                  Text(
                    phoneNumber,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                    ),

                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            width: 300,
            decoration: BoxDecoration(
              color: textContainerColor, borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Text(
                  "İlgi Alanlarınız",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Wrap(
                  children: categories.map((e) => Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      "\u2022 " + e,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 20,),
                ButtonMain(text: "Ekle/Kaldır", action: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => AbilitiesPage()));
                }, width: 250, height: 50, buttonColor: gradiendColor2,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
