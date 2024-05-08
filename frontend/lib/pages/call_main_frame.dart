import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/webrtc/web_rtc_controller.dart';
import 'package:frontend/custom_widgets/appbars/video_call_bar.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';
import 'package:image/image.dart';

import '../controller/webrtc/dto/call_request.dart';
import '../util/secure_storage.dart';
import '../util/types.dart';

class CallMainFrame extends StatefulWidget {
  static const String routeName = "/callMainFrame";
  final String callId;
  final String callActionType;


  const CallMainFrame(
      {Key? key, required this.callId, required this.callActionType})
      : super(key: key);

  @override
  CallMainFrameState createState() => CallMainFrameState();
}

class CallMainFrameState extends State<CallMainFrame> {
  String calleeName = "";
  late WebRTCController webRTCController;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool isFlashlightOn = false;
  bool isRemoteStreamReceived = false;
  CallRequest? callRequest;
  UserType? userType;

  @override
  void initState() {
    webRTCController = WebRTCController(updateCalleeName: updateCalleeName, getCallRequest: getCallRequest);
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    webRTCController
        .openUserMedia(_localRenderer, _remoteRenderer)
        .then((value) {
      startWebRTC();
      setState(() {});
    });
    webRTCController.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {
        isRemoteStreamReceived = true;
      });
    });
    getUserType();

    super.initState();
  }

  Future<void> startWebRTC() async {
    if (widget.callActionType == "start") {
      await webRTCController.startCall(_remoteRenderer, widget.callId);
    } else if (widget.callActionType == "accept") {
      await webRTCController.acceptCall(_remoteRenderer, widget.callId);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    webRTCController.dispose();
    super.dispose();
  }

  Future<void> getUserType() async {
    String? type = SecureStorageManager.readFromCache(key: StorageKey.role);
    type ??= await SecureStorageManager.read(key: StorageKey.role);
    setState(() {
      userType = stringToUserType(type!);
    });
  }

   CallRequest? getCallRequest (CallRequest callRequest) {
    setState(() {
      this.callRequest = callRequest;
    });
    print("debug");
    print(this.callRequest);
  }

  void updateCalleeName(String name) {
    setState(() {
      calleeName = name;
    });
  }

  void handleButtonStateChanged(ButtonType buttonType, bool isButtonOn) {
    switch (buttonType) {
      case ButtonType.MIC:
        webRTCController.toggleAudio(isButtonOn);
        setState(() {});
        break;
      case ButtonType.Video:
        webRTCController.toggleVideo(isButtonOn);
        setState(() {});
        break;
      case ButtonType.Speaker:
        webRTCController.toogleSpeaker(isButtonOn);
        setState(() {});
        break;
      case ButtonType.Camera:
        webRTCController.switchVideo();
        setState(() {});
        break;
      case ButtonType.HangUp:
        webRTCController.hangUp();
        setState(() {});
        break;
    }
  }

  void toggleFlashlight() {
    setState(() {
      isFlashlightOn = !isFlashlightOn;
    });
    webRTCController.toggleTorch(isFlashlightOn);
  }
  // VIDEO call initalization screen

  Widget getMainCallWidget() {
    if (!isRemoteStreamReceived || userType == null) {
      return Container(
        color: Colors.white,
      );
    }
    if (userType == UserType.volunteer || (callRequest != null && callRequest!.isConsultancyCall == true)) {
      return RTCVideoView(_remoteRenderer);
    }
    return RTCVideoView(_localRenderer, mirror: true);
  }

  @override
  Widget build(BuildContext context) {
    webRTCController.setContext(context);
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
                child: getMainCallWidget(),
              ),
            ),
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