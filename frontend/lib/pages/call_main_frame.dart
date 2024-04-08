import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/webrtc/web_rtc_controller.dart';
import 'package:frontend/custom_widgets/appbars/video_call_bar.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import "package:socket_io_client/socket_io_client.dart" as IO;

class CallMainFrame extends StatefulWidget {
  const CallMainFrame({Key? key}) : super(key: key);
  static const String routeName = "/callMainFrame";

  @override
  _CallMainFrameState createState() => _CallMainFrameState();
}

class _CallMainFrameState extends State<CallMainFrame> {
  String calleeName = "Callee Name";
  WebRTCController webRTCController = WebRTCController();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  IO.Socket? socket;
  late String callID;
  bool isFlashlightOn = false; // Track flashlight state

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    webRTCController
        .openUserMedia(_localRenderer, _remoteRenderer)
        .then((value) {
      setState(() {});
    });
    webRTCController.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  // TODO; Delete later
  TextEditingController _textEditingController = TextEditingController();

  void handleButtonStateChanged(ButtonType buttonType, bool isButtonOn) {
    switch (buttonType) {
      case ButtonType.MIC:
        // Handle Mic button state change
        print("Mic button pressed");
        webRTCController.toggleAudio(isButtonOn);
        setState(() {});
        break;
      case ButtonType.Video:
        webRTCController.toggleVideo(isButtonOn);
        setState(() {});
        // Handle Video button state change
        print("Video button pressed");
        break;
      case ButtonType.Speaker:
        webRTCController.toogleSpeaker(isButtonOn);
        setState(() {});
        // Handle Speaker button state change
        print("Speaker button pressed");
        break;
      case ButtonType.Camera:
        webRTCController.switchVideo();
        setState(() {});
        // Handle Camera button state choange
        print("Camera button pressed");
        break;
      case ButtonType.HangUp:
        // Handle HangUp button state change
        webRTCController.hangUp(_localRenderer);
        setState(() {});
        print("HangUp button pressed");
        break;
    }
  }

  void toggleFlashlight() {
    setState(() {
      isFlashlightOn = !isFlashlightOn;
    });
    webRTCController.toggleTorch(isFlashlightOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: RTCVideoView(_remoteRenderer))),
            // Add button here
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter text here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(children: [
                  ElevatedButton(
                    onPressed: () async {
                      await webRTCController.startCall(_remoteRenderer, "fast");
                    },
                    child: Text('call'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      webRTCController.acceptCall(
                          _remoteRenderer, _textEditingController.text);
                      setState(() {});
                    },
                    child: Text('answer'),
                  ),
                ])
              ],
            )),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: Icon(isFlashlightOn ? Icons.flash_on : Icons.flash_off),
                onPressed: () {
                  toggleFlashlight();
                },
              ),
            ),
            Positioned(
                top: 16.0,
                right: 16.0,
                child: Container(
                    width: 120.0,
                    height: 160.0,
                    color: Colors.black,
                    child: RTCVideoView(_localRenderer, mirror: true))),
            Positioned(
              top: 20,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: VideoCallName(line: calleeName),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: TransparentVideoCallBar(
                onButtonStateChanged: handleButtonStateChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
