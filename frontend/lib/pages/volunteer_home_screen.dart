import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/abililities_page.dart';
import 'package:frontend/pages/profile_screen.dart';

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
  int numberOfHelpedBlindPeople = 2;

  getUserInfo() async {

    username = SecureStorageManager.readFromCache(key: StorageKey.name)
        ?? await SecureStorageManager.read(key: StorageKey.name) ?? "";
    categories = SecureStorageManager.readListFromCache(key: StorageKey.abilities) ??
        await SecureStorageManager.readList(key: StorageKey.abilities) ?? [];
    phoneNumber = SecureStorageManager.readFromCache(key: StorageKey.phone_number)
        ?? await SecureStorageManager.read(key: StorageKey.phone_number) ?? "";

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    
    print(MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top);

    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: [
              Image.asset(
                "assets/home_image.png",
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Merhaba $username 👋",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColorLight,
                          ),

                        ),
                        Text(
                          phoneNumber,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            color: textColorLight,
                          ),

                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                      },
                      icon: const Icon(
                        Icons.person,
                        color: textColorLight,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                width: 300,
                decoration: BoxDecoration(
                  color: secondaryColor, borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                    "Şu ana kadar $numberOfHelpedBlindPeople kişiye yardım ettiniz! Çok teşekkür ederiz.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: textColorLight,
                    )
                ),
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AbilitiesPage()));
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 300,
                  decoration: BoxDecoration(
                    color: secondaryColor, borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "İlgi Alanlarınız",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColorLight,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: textColorLight,
                            size: 18,
                          ),
                        ],
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
                              color: textColorLight,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
