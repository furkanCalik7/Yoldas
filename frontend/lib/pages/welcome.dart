import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_big.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)
                  ),
              margin: EdgeInsets.fromLTRB(0, 100, 0, 30),
              child: Icon(
                Icons.blind,
                size: 200.0,
              ),
            ),
            Center(
              child: TextHead(line: "YOLDAS"),
            ),
            ButtonBig(text: "Giris Yap", action: () {}),
            SizedBox(
              height: 20.0,
            ),
            ButtonBig(text: "Kaydol", action: () {})
          ],
        ),
      ),
    );
  }
}
