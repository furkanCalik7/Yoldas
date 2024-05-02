import 'package:flutter/material.dart';
import 'package:frontend/controller/gpt_controller.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/pages/ai_model_view.dart';

import '../controller/currency_recognizer_controller.dart';
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
  Icons.document_scanner,
  Icons.image,
];

class AIModelSelectionPage extends StatefulWidget {
  @override
  State<AIModelSelectionPage> createState() => _AIModelSelectionPageState();
}

class _AIModelSelectionPageState extends State<AIModelSelectionPage> {
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
              controller: GPTController(
                  prompt: 'Belgedeki içeriği özetleyecek bir şekilde '
                      'açıklayın, içerikte bulunan önemli detayları aktarın. Sunulan bilgilerin kapsamlı'
                      ' bir özetini sağlayarak tüm önemli noktaların doğru bir şekilde iletilmesini sağlayın. '
                      'Ayrıca, belgenin düzenini ve biçimlendirmesini açıklayarak yapısını'
                      ' anlamaya yardımcı olun. Fatura ve fiş gibi belgelerde bulunan toplam tutar'
                      ' gibi önemli sayıları doğru bir şekilde belirtin.'
                      ' Resimde belge bulunmuyorsa sadece "Belge bulunamadı" yazın.'),
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

    CustomSwiper customSwiper = CustomSwiper(
      titles: models,
      icons: icons,
      action: (index) {
        setState(() {
          selectedIndex = index;
        });
        flutterTTs.speak(models[index]);
      },
    );

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          customSwiper,
          const SizedBox(
            height: 50,
          ),
          ButtonMain(
            text: "Başlat",
            height: MediaQuery.of(context).size.height * 0.075,
            width: MediaQuery.of(context).size.width * 0.5,
            semanticLabel: "${models[selectedIndex]} modelini başlat",
            action: () {
              navigateToModel(context, selectedIndex);
            },
          ),
        ],
      ),
    );
  }
}
