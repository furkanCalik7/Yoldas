import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  var name = "Dummy Name";
  var surname = "Dummy Surname";
  var email = "can.yilmaz@gmail.com";
  var phoneNumber = "05076009363";

  Future _updateFieldsFromStorage() async {
    name = await storage.read(key: "name") ?? "N/A";
    email = await storage.read(key: "email") ?? "N/A";
    phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
    setState(() {});
  }

  @override
  void initState() {
    _updateFieldsFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Profil",
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: getBackgroundDecoration(),
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
