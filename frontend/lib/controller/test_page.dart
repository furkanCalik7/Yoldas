import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/socket_controller.dart';
import 'package:frontend/controller/webrtc/signaling.dart';
import 'package:frontend/controller/webrtc/web_rtc_controller2.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  static const String routeName = "/testPage";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  SocketController socketController = SocketController.instance;
  WebRTCController webRTCController = WebRTCController();

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // signaling.openUserMedia(_localRenderer, _remoteRenderer).then((value) {
                  //   setState((){});
                  
                  webRTCController.openUserMedia(_localRenderer, _remoteRenderer).then((value) {
                    setState((){});  
                  });
                },
                child: Text("Open camera & microphone"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  // socketController.getConnection().then((value) {
                  //   print("Socket: $value");
                  //   webRTCController.createRoom(
                  //       _remoteRenderer, value, "fast");
                  // }); 
                  await webRTCController.createRoom(
                      _remoteRenderer, "fast");
                  // webRTCController.requestCall(_remoteRenderer);
                  // roomId = await signaling.createRoom(_remoteRenderer);
                  // textEditingController.text = roomId!;
                  // setState(() {});
                },
                child: Text("Create room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  // signaling.joinRoom(
                  //   textEditingController.text.trim(),
                  //   _remoteRenderer,
                  // );
                  webRTCController.joinRoom(
                      _remoteRenderer, textEditingController.text);
                    

                  // socketController.getConnection().then((value) {
                  //   print("Socket: $value");
                  //   print("Call ID: ${textEditingController.text}");
                  //   print("here");
                    
                  // });
                },
                child: Text("Join room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("Hangup"),
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
