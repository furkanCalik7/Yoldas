import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/button_default.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 244, 1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)
                  //more than 50% of width makes circle
                  ),
              margin: EdgeInsets.fromLTRB(0, 100, 0, 30),
              child: Icon(
                Icons.blind,
                size: 200.0,
              ),
            ),
            Center(
              child: Text(
                "YOLDAS",
                style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    fontFamily: "WendyOne"),
              ),
            ),
            ButtonDefault(text: "Giris Yap", action: () {}),
            SizedBox(
              height: 20.0,
            ),
            ButtonDefault(text: "Kaydol", action: () {})
          ],
        ),
      ),
    );
  }
}
