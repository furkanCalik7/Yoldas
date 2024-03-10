import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/custom_text_field.dart';
import 'package:frontend/custom_widgets/sheets/edit_profile_sheet.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Profil",
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: getBackgroundDecoration(),
        child: Center(
          child: EditProfileSheet(),
        ),
      ),
    );
  }
}
