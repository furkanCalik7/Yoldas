import 'package:flutter/material.dart';

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
  const AIModelSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            height: 400,
            child: const CustomSwiper(
              titles: models,
              icons: icons,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ButtonMain(
            text: "Kullanmaya Başla",
            action: () {
              Navigator.pushNamed(context, ObjectDetectionCameraView.routeName);
            },
            height: 80,
            width: 400,
          ),
        ],
      );
  }
}
