import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:frontend/custom_widgets/appbars/appbar_custom.dart";
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import "package:frontend/pages/blind_main_frame.dart";
import "package:frontend/pages/volunteer_main_frame.dart";
import "package:frontend/utility/types.dart";
import "package:frontend/config.dart";
import "package:http/http.dart" as http;
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({Key? key}) : super(key: key);

  static const String routeName = "/evaluation";

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  var point = 3.0;
  final controller = TextEditingController();

  FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<UserType> getUserType() async {
    return await storage.read(key: "role") == userTypeToString(UserType.blind)
        ? UserType.blind
        : UserType.volunteer;
  }

  Future<void> navigateToNextScreen() async {
    UserType userType = await getUserType();

    if (userType == UserType.blind) {
      Navigator.pushNamedAndRemoveUntil(
          context, BlindMainFrame.routeName, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, VolunteerMainFrame.routeName, (route) => false);
    }
  }

  Future<void> sendEvaluation() async {
    String phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
    print(point);

    String path = "$API_URL/users/send_feedback/";

    Map<String, dynamic> requestBody = {
      "rating": point,
      "callID": "NxSbReykcZHYqWa4WpU8",
    };

    final response = await http.post(
      Uri.parse(path),
      body: jsonEncode(requestBody),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.read(key: "access_token")}',
      },
    );

    if (response.statusCode == 200) {
      await navigateToNextScreen();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Değerlendirmeniz gönderildi."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Değerlendirmeniz gönderilemedi."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Değerlendirme",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const SubTitleText(line: "Görüşmeyi Değerlendirin"),
              RatingBar.builder(
                onRatingUpdate: (rating) {
                  setState(() {
                    point = rating;
                  });
                },
                allowHalfRating: true,
                initialRating: 3,
                itemCount: 5,
                itemSize: 60.0,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonMain(
                      text: "Gönder",
                      width: 150,
                      height: 75,
                      fontSize: 30.0,
                      action: () {
                        sendEvaluation();
                      }),
                  const SizedBox(
                    width: 20.0,
                  ),
                  ButtonMain(
                    text: "Geç",
                    width: 150,
                    height: 75,
                    fontSize: 30.0,
                    action: navigateToNextScreen,
                  )
                ],
              ),
              ButtonMain(
                text: "Şikayet Et",
                height: 75,
                fontSize: 30.0,
                action: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
