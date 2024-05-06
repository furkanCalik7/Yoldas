import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:http/http.dart';

class ComplaintPage extends StatelessWidget {
  ComplaintPage({Key? key, required this.callId}) : super(key: key);

  final String callId;
  final TextEditingController controller = TextEditingController();

  void sendComplaint(BuildContext context, String complaint) async {
    String accessToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

    if (accessToken == "N/A") {
      print("Access token is not found");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı bilgilerine ulaşılamadı."),
        ),
      );
      return;
    }

    String path = "/users/complaint";

    Response response = await ApiManager.post(
      path: path,
      bearerToken: accessToken,
      body: {
        "callID": callId,
        "complaint": complaint,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şikayetiniz başarıyla gönderildi."),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şikayet gönderilirken bir hata oluştu."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppbarCustom(
          title: "Şikayet Et",
        ),
        body: Container(
          decoration: getBackgroundDecoration(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Şikayetinizi buraya yazabilirsiniz.",
                      style: TextStyle(
                        fontSize: 20,
                        color: textColorLight,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                      ),
                      child: TextField(
                        controller: controller,
                        maxLines: 10,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonMain(
                          text: "Gönder",
                          width: MediaQuery.of(context).size.width * 0.4,
                          action: () {
                            sendComplaint(context, controller.text);
                          },
                        ),
                        const Spacer(),
                        ButtonMain(
                          text: "İptal",
                          width: MediaQuery.of(context).size.width * 0.4,
                          action: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
