import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
class ButtonMain extends StatelessWidget {

  final String text;
  final Function action;
  final double height;
  final double width;


  ButtonMain({
    required this.text,
    required this.action,
    this.height = 40,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () { action();},
        child: Text(text,
          style: TextStyle (
              fontSize: height / 2,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(defaultButtonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
      ),
    );
  }
}
