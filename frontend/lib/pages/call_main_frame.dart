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
                  decoration: InputDecoration(
                    hintText: 'Enter text here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(children: [
                  ElevatedButton(
                    onPressed: () async {
                      await webRTCController.createRoom(
                          _remoteRenderer, "fast");
                    },
                    child: Text('call'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      webRTCController.joinRoom(
                          _remoteRenderer, _textEditingController.text);
                      setState(() {});
                    },
                    child: Text('answer'),
                  ),
                ])
              ],
            )),

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
