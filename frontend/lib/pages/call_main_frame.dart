import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/video_call_bar.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class CallMainFrame extends StatefulWidget {
  const CallMainFrame({Key? key}) : super(key: key);

  static const String routeName = "/callMainFrame";

  @override
  _CallMainFrameState createState() => _CallMainFrameState();
}

class _CallMainFrameState extends State<CallMainFrame> {
  String calleeName = "Callee Name";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // this sized box's child will be the video screen
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    "Video Screen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: VideoCallName(line: calleeName),
                ),
              ),
            ),
            const Positioned(
              bottom: 0,
              child: TransparentVideoCallBar(),
            ),
          ],
        ),
      ),
    );
  }
}
