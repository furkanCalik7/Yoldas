import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/loading_indicator.dart';
import 'package:frontend/util/login.dart';
import 'package:frontend/custom_widgets/colors.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({Key? key}) : super(key: key);

  @override
  _InitializationPageState createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  @override
  void initState() {
    super.initState();
    Login.tryLoginWithoutSMSVerification(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: primaryColor,
        child: const LoadingIndicator(),
      ),
    );
  }
}
