import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/text_widgets/text_container_custom.dart';

import '../custom_widgets/colors.dart';
import '../custom_widgets/text_widgets/text_container.dart';

class VolunteerHomeScreen extends StatelessWidget {
  final String username;
  final List<String> categories;
  final DateTime joinDate;

  // Named constructor
  VolunteerHomeScreen(String username, DateTime date, List<String> categories,)
      : this.username = username,
        this.joinDate = date,
        this.categories = categories;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextContainer(text: "Hos Geldiniz"),
          Container(
            height: 150,
            width: 300,
            decoration: BoxDecoration(
              color: textContainerColor, borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    "${joinDate.day}-${joinDate.month}-${joinDate.year} tarihinden beri üyesiniz",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
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
                )).toList(
                ),
                ),
                SizedBox(height: 20,),
                ButtonMain(text: "Ekle/Kaldır", action: () {}, width: 250, height: 50,)
              ],
            ),
          )
        ],
      ),
    );
  }
}
