import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'dart:async';
import 'dart:math';

class ButtonMain extends StatefulWidget {
  const ButtonMain({
    Key? key,
    required this.text,
    required this.action,
    this.height = 40,
    this.width = 200,
    this.fontSize = 0.0,
    this.buttonColor = tertiaryColor,
    this.semanticLabel = "",
  }) : super(key: key);

  final String text;
  final void Function()? action;
  final double height;
  final double width;
  final double fontSize;
  final Color buttonColor;
  final String semanticLabel;

  @override
  _ButtonMainState createState() => _ButtonMainState();
}

class _ButtonMainState extends State<ButtonMain> {
  bool _isButtonDisabled = false;

  double determineFontSize() {
    return min(widget.height / 2, widget.width / 4);
  }

  void _onButtonPressed() {
    if(widget.action == null) {
      return;
    }
    if (!_isButtonDisabled) {
      print("(test) triggerd");
      setState(() {
        _isButtonDisabled = true;
      });
      widget.action?.call();
      Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          _isButtonDisabled = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Semantics(
        label: widget.semanticLabel,
        excludeSemantics: widget.semanticLabel != "",
        child: ElevatedButton(
          onPressed: _onButtonPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey; // Color when disabled
              }
              return widget.buttonColor; // Default color
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.fontSize == 0.0 ? determineFontSize() : widget.fontSize,
              fontWeight: FontWeight.bold,
              color: textColorDark,
            ),
          ),
        ),
      ),
    );
  }
}
