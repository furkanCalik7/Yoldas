import 'package:flutter/material.dart';

class ButtonDefault extends StatelessWidget {

  final String text;
  final Function action;

  ButtonDefault({required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 326,
      child: ElevatedButton(
        onPressed: () { action();},
        child: Text(text,
          style: TextStyle(
              fontSize: 32,
              fontFamily: "WendyOne",
              color: Colors.black
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(247, 181, 56, 1)),
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
