import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/custom_widgets/colors.dart';

class VolunteerSearchScreen extends StatefulWidget {
  @override
  _VolunteerSearchScreenState createState() => _VolunteerSearchScreenState();

  static const String routeName = "/volunteer_search_screen";
}

class _VolunteerSearchScreenState extends State<VolunteerSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  late FlutterTts flutterTts;

  double _radius = 30.0; // Radius of circular path

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("tr-TR");
    flutterTts.speak("Uygun gönüllü aranıyor");
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _rotationAnimation = Tween<double>(begin: math.pi / 16, end: -math.pi / 16)
        .animate(_animationController);
    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, _radius),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.cos(_rotationAnimation.value * 4) * _radius,
                    math.sin(_rotationAnimation.value * 4) * _radius,
                  ),
                  child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Image.asset(
                        "assets/search_icon.png",
                        width: 125,
                        height: 125,
                      )),
                );
              },
            ),
            SizedBox(height: 40),
            Text(
              'Uygun gönüllü aranıyor...',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            // add hang up button
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.call_end, size: 50, color: Colors.white),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(redIconButtonColor),
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
