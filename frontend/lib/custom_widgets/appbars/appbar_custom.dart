import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:frontend/custom_widgets/colors.dart';

class AppbarCustom extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  String title;

  AppbarCustom({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          letterSpacing: 10,
        ),
      ),
      backgroundColor: defaultButtonColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
    );
  }
}
