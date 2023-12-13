import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final name = "Can";
  final surname = "Yılmaz";
  final email = "can.yilmaz@gmail.com";
  final phoneNumber = "05076009363";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Profil",
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.fromLTRB(0, 100, 0, 30),
              child: const Icon(
                Icons.person,
                size: 200.0,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileText(line: "Name: $name"),
                ButtonMain(
                    text: "Edit",
                    height: 30.0,
                    width: 75,
                    action: () {
                      print("Edit name pressed");
                    }),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileText(line: "Email: $email"),
                ButtonMain(
                    text: "Edit",
                    height: 30.0,
                    width: 75,
                    action: () {
                      print("Edit email pressed");
                    }),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileText(line: "Phone Number: $phoneNumber"),
                ButtonMain(
                    text: "Edit",
                    height: 30.0,
                    width: 75,
                    action: () {
                      print("Edit phone number pressed");
                    }),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ProfileText(line: "Password: ********"),
                ButtonMain(
                    text: "Edit",
                    height: 30.0,
                    width: 75,
                    action: () {
                      print("Edit password pressed");
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
