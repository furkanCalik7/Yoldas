import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/sheets/edit_profile_sheet.dart';
import 'package:frontend/custom_widgets/colors.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
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
