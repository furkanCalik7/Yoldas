import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = videoCallButtonDefaultColor,
    this.iconColor = Colors.white,
    this.iconSize = 32.0,
    this.tooltip = '',
  }) : super(key: key);

  final Function onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      iconSize: iconSize,
      onPressed: () {
        onPressed();
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(15),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(iconSize),
          ),
        ),
      ),
      icon: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
