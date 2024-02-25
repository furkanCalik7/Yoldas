import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/socket_controller.dart';
import 'package:frontend/controller/web_rtc_controller.dart';
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
  SocketController socketController = SocketController.instance;
  WebRTCController webRTCController = WebRTCController();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    webRTCController.openUserMedia(_localRenderer, _remoteRenderer);
    webRTCController.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    socketController.getConnection().then((socket) {
      webRTCController.requestCall(_remoteRenderer, socket);
    });
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // this sized box's child will be the video screen
            Center(
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: RTCVideoView(_remoteRenderer))),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   child: Container(
            //     color: Colors.blue,
            //     child: RTCVideoView(_localRenderer, mirror: true)
            //     ),
            // ),
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
