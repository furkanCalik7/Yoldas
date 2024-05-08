import 'package:flutter/material.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';

import '../custom_widgets/colors.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: 'Hakkında',
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        padding: EdgeInsets.all(20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yoldaş Uygulaması',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColorLight),
            ),
            SizedBox(height: 16),
            Text(
              'Sürüm: 1.0.0',
              style: TextStyle(fontSize: 18, color: textColorLight),
            ),
            SizedBox(height: 8),
            Text(
              'Açıklama: Yoldaş, görme engelli bireylere günlük aktivitelerinde yardımcı olmak için tasarlanmış bir uygulamadır. Hızlı arama, kişiselleştirilmiş arama, yapay zeka modelleri gibi özellikler sunar.',
              style: TextStyle(fontSize: 18, color: textColorLight),
            ),
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    'Şikayet ve önerileriniz için:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColorLight),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'yoldas.app.team@gmail.com',
                    style: TextStyle(fontSize: 18, color: textColorLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
