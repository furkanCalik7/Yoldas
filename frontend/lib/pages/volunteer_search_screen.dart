import 'dart:math' as math;
import 'package:flutter/material.dart';

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

  double _radius = 30.0; // Radius of circular path

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _rotationAnimation =
        Tween<double>(begin: math.pi / 8, end: -math.pi / 16).animate(_animationController);
    _positionAnimation = Tween<Offset>(
      begin: Offset(0,_radius),
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
      backgroundColor: Colors.blue,
      appBar: AppBar(
        forceMaterialTransparency: true,

      ),
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
                    child: Icon(Icons.search_rounded, size: 70),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            Text(
              'Searching for a volunteer...',
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}
