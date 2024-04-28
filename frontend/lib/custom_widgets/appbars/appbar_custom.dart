import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class AppbarCustom extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  String title;

  AppbarCustom({required this.title});

  @override
  Widget build(BuildContext context) {

    ModalRoute? parentRoute = ModalRoute.of(context);
    bool back = parentRoute?.impliesAppBarDismissal ?? false;
    return AppBar(
      title: AppBarText(
        line: title,
      ),
      leading: back ? Semantics(
        label: "Geri",
        button: true,
        excludeSemantics: true,
        child: IconButton(

          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ) : null,
      iconTheme: const IconThemeData(
        color: textColorLight,
      ),
      backgroundColor: secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
    );
  }
}
