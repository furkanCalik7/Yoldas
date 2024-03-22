import 'package:flutter/material.dart';
import 'package:frontend/controller/gpt_controller.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/pages/ai_model_view.dart';
import 'package:frontend/pages/currency_recognition_camera_view.dart';
import 'package:frontend/pages/text_recognition_view.dart';

import '../controller/currency_recognizer_controller.dart';
import '../custom_widgets/appbars/appbar_custom.dart';
import '../custom_widgets/buttons/button_main.dart';
import '../custom_widgets/swiper/custom_swiper.dart';

const List<String> models = [
  "Para tanıma",
  "Metin tanıma",
  "Belge tanıma",
  "Resim tanıma",
];

const List<IconData> icons = [
  Icons.money,
  Icons.text_fields,
  Icons.file_copy,
  Icons.image,
];

class AIModelSelectionPage extends StatelessWidget {

  int selectedIndex = 0;

  void navigateToModel(context, index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AIModelView(
              controller: CurrencyRecognizerController(),
              title: "Para Tanıma",
            ),
          ),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AIModelView(
              controller: TextRecognizerController(),
              title: "Metin Tanıma",
            ),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AIModelView(
              controller: GPTController(prompt: 'Bu resimde ne var?'),
              title: "Belge Tanıma",
            ),
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AIModelView(
              controller: GPTController(prompt: 'Bu resimde ne var?'),
              title: "Resim Tanıma",
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedIndex = 0;



    CustomSwiper customSwiper = CustomSwiper(
      titles: models,
      icons: icons,
      action: (index) {
        selectedIndex = index;
      },
    );

    return Column(
        children: [
          Container(
            height: 350,
            child: customSwiper,
          ),
          const SizedBox(
            height: 50,
          ),
          ButtonMain(
            text: "Başlat",
            action: () {
              navigateToModel(context, selectedIndex);
            },
            height: 100,
            width: 350,
            fontSize: 40,
          ),
        ],
      );
  }
}
