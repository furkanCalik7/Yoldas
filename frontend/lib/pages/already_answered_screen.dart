import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:frontend/util/types.dart';
import 'package:frontend/pages/blind_main_frame.dart';
import 'package:frontend/pages/volunteer_main_frame.dart';

class AlreadyAnsweredScreen extends StatelessWidget {
  const AlreadyAnsweredScreen({Key? key}) : super(key: key);

  void skip(BuildContext context) async {
    String? role = await SecureStorageManager.read(key: StorageKey.role);
    UserType? userType = stringToUserType(role!);

    if (userType == UserType.blind) {
      Navigator.pushNamedAndRemoveUntil(
          context, BlindMainFrame.routeName, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, VolunteerMainFrame.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: getBackgroundDecoration(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SubTitleText(
                line:
                    "Thank you for your response! However, someone already arrived for help. We appreciate your kindness! 🎉",
                size: 20,
              ),
              ButtonMain(
                text: "Ana Sayfaya Dön",
                action: () {
                  skip(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
