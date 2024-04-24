import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:frontend/custom_widgets/appbars/appbar_custom.dart";
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import "package:frontend/pages/blind_main_frame.dart";
import "package:frontend/pages/complaint_page.dart";
import "package:frontend/pages/volunteer_main_frame.dart";
import "package:frontend/util/api_manager.dart";
import 'package:frontend/util/secure_storage.dart';
import "package:frontend/util/types.dart";

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({Key? key, required this.callId}) : super(key: key);

  static const String routeName = "/evaluation";
  final String callId;

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  var point = 3.0;
  final controller = TextEditingController();

  Future<UserType> getUserType() async {
    return await SecureStorageManager.read(key: StorageKey.role) ==
            userTypeToString(UserType.blind)
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
    print(point);
    String accessToken = SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

    String path = "/users/feedback";

    Map<String, dynamic> requestBody = {
      "rating": point,
      "callID": widget.callId,
    };

    final response = await ApiManager.post(
      path: path,
      bearerToken: accessToken,
      body: requestBody,
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
        padding: const EdgeInsets.all(20.0),
        decoration: getBackgroundDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SubTitleText(line: "Görüşmeyi Değerlendirin"),
              RatingBar.builder(
                onRatingUpdate: (rating) {
                  setState(() {
                    point = rating;
                  });
                },
                allowHalfRating: false,
                initialRating: 3,
                itemCount: 5,
                itemSize: 60.0,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: tertiaryColor,
                  shadows: [Shadow(color: tertiaryColor, blurRadius: 20)],
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
                fontSize: 30.0,
                height: 75,
                buttonColor: Colors.red,
                action: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ComplaintPage()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
