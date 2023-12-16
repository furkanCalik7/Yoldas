import 'package:flutter/material.dart';
import 'package:frontend/pages/text_recognition_view.dart';

import '../custom_widgets/appbars/appbar_custom.dart';
import '../custom_widgets/buttons/button_main.dart';
import '../custom_widgets/swiper/custom_swiper.dart';
import 'object_detection_camera_view.dart';

const List<String> models = [
  "Para tanıma",
  "Metin tanıma",
  "Obje tanıma",
  "Belge tanıma"
];

const List<IconData> icons = [
  Icons.money,
  Icons.text_fields,
  Icons.image,
  Icons.file_copy
];

class AIModelSelectionPage extends StatelessWidget {

  int selectedIndex = 0;

  void navigateToModel(context, index) {
    switch (index) {
      case 0:
        print("Index = 0");
        break;
      case 1:
        Navigator.pushNamed(context, TextRecognitionCameraView.routeName);
        break;
      case 2:
        Navigator.pushNamed(context, ObjectDetectionCameraView.routeName);
        break;
      case 3:
        print("Index = 3");
    }
  }

  @override
  Widget build(BuildContext context) {



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
            height: 400,
            child: customSwiper,
          ),
          const SizedBox(
            height: 50,
          ),
          ButtonMain(
            text: "Kullanmaya Başla",
            action: () {
              navigateToModel(context, selectedIndex);
            },
            height: 80,
            width: 400,
          ),
        ],
      );
  }
}
