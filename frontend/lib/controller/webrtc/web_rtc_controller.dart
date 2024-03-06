import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class IceCandidateHandler {
  String? callId;
  List<RTCIceCandidate?> iceCandidates = [];
  IO.Socket socket;
  CallUser callUser;

  IceCandidateHandler({required this.socket, required this.callUser});

  void handleIceCandidate(RTCIceCandidate? candidate) {
    if (candidate == null) {
      print("Ice candidates completed");
      return;
    }

    if (callId != null) {
      // If callId is available, send ICE candidates immediately
      sendIceCandidate(candidate);
    } else {
      // If callId is not available yet, store ICE candidates
      iceCandidates.add(candidate);
    }
  }

  void sendIceCandidate(RTCIceCandidate candidate) {
    print('Sending candidate: ${candidate.toMap()}');
    IceCandidateMessage iceCandidate =
        IceCandidateMessage(callID: callId!, iceCandidate: candidate);

    // Assuming `socket.emit` is a function to send data over the socket
    socket.emit(
        '${callUser.name}_ice_candidate', jsonEncode(iceCandidate.toJSON()));
  }

  void setCallId(String id) {
    callId = id;
    // Process any stored ICE candidates after receiving callId
    iceCandidates.forEach((candidate) {
      sendIceCandidate(candidate!);
    });
    // Clear stored ICE candidates after sending them
    iceCandidates.clear();
  }
}

typedef void StreamStateCallback(MediaStream stream);

enum SignalType { offer, answer }

enum CallUser { callee, caller }

class CallRequest {
  CallRequest(
      {required this.type, required this.phoneNumber, required this.signal});

  String type;
  String phoneNumber;
  Signal signal;

  toJSON() {
    return {
      'type': type,
      "phone_number": phoneNumber,
      "signal": signal.toJSON()
    };
  }
}

class CallAccept {
  CallAccept({required this.callID, required this.phoneNumber});

  String callID;
  String phoneNumber;

  toJSON() {
    return {'call_id': callID, 'phone_number': phoneNumber};
  }
}

class Signal {
  Signal({required this.type, required this.sdp});

  SignalType type;
  String sdp;

  toJSON() {
    return {'type': type.name, 'sdp': sdp};
  }
}

class SignalMessage {
  SignalMessage({required this.callID, required this.signal});

  late String callID;
  late Signal signal;

  toJSON() {
    return {"call_id": callID, "signal": signal.toJSON()};
  }
}

class IceCandidateMessage {
  IceCandidateMessage({required this.callID, required this.iceCandidate});

  late String callID;
  RTCIceCandidate? iceCandidate;
  toJSON() {
    return {'call_id': callID, 'ice_candidate': iceCandidate!.toMap()};
  }
}

class WebRTCController {
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  StreamStateCallback? onAddRemoteStream;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  // TODO: Make type parameter enum
  Future<String> requestCall(
      RTCVideoRenderer remoteRenderer, IO.Socket socket, String type) async {
    _peerConnection = await createPeerConnection(_configuration);
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    if (offer.sdp == null) throw Exception("offer.sdp is null");
    await _peerConnection!.setLocalDescription(offer);
    Signal signal = Signal(type: SignalType.offer, sdp: offer.sdp!);
    IceCandidateHandler iceCandidateHandler =
        IceCandidateHandler(socket: socket, callUser: CallUser.caller);
    _peerConnection?.onIceCandidate = iceCandidateHandler.handleIceCandidate;

    socket.on("answer_to_caller", (data) {
      var answerJson = jsonDecode(data) as Map<String, dynamic>;
      var signal = answerJson['signal'];
      var answer = RTCSessionDescription(
        signal['sdp'],
        signal['type'],
      );
      print("Someone tried to connect");
      _peerConnection?.setRemoteDescription(answer);
    });

    CallRequest callRequest = CallRequest(
        type: type,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A",
        signal: signal);

    Completer<String> completer = Completer<String>();
    http.post(
        Uri.parse(
          "$API_URL/calls/call",
        ),
        body: jsonEncode(callRequest.toJSON()),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
        }).then((value) {  
      var callJson = jsonDecode(value.body);
      iceCandidateHandler.setCallId(callJson["call_id"]);

      _sendPeerConnection(
          remoteRenderer, socket, CallUser.caller, callJson["call_id"]);

      completer.complete(callJson["call_id"]);
    });
    return completer.future;
  }

  Future<void> acceptCall(
      RTCVideoRenderer remoteRenderer, IO.Socket socket, String callID) async {
    CallAccept callAccept = CallAccept(
        callID: callID,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A");

    _peerConnection = await createPeerConnection(_configuration);
    IceCandidateHandler iceCandidateHandler =
        IceCandidateHandler(socket: socket, callUser: CallUser.callee);

    _peerConnection?.onIceCandidate = iceCandidateHandler.handleIceCandidate;
    _sendPeerConnection(remoteRenderer, socket, CallUser.callee, callID);

    http.post(
        Uri.parse(
          "$API_URL/calls/call/accept",
        ),
        body: jsonEncode(callAccept.toJSON()),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
        }).then((value) {
          print(value);
      iceCandidateHandler.setCallId(callID);
      var signal = jsonDecode(value.body)['offer'];
      RTCSessionDescription offer = RTCSessionDescription(
        signal['sdp'],
        signal['type'],
      );
      _peerConnection?.setRemoteDescription(offer);
      _peerConnection?.createAnswer().then((value) {
        _peerConnection?.setLocalDescription(value);
        Signal signal = Signal(type: SignalType.answer, sdp: value.sdp!);
        SignalMessage signalMessage =
            SignalMessage(callID: callID, signal: signal);
        socket.emit("answer_signal", jsonEncode(signalMessage.toJSON()));
      }); 
    });
    // socket.emit("call_accept", jsonEncode(callAccept.toJSON()));
    // socket.on("call_accept_response", (data) {
    //   _sendPeerConnection(remoteRenderer, socket, CallUser.callee, callID);
    // });
  }

  Future<void> _sendPeerConnection(RTCVideoRenderer remoteRenderer,
      IO.Socket socket, CallUser callUser, String callID) async {
    print(
        '$callUser: Create PeerConnection with configuration: $_configuration');
    print("CallID: $callID");

    registerPeerConnectionListeners();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        print("${callUser.name}_ice_candidates_completed");
        socket.emit("${callUser.name}_ice_candidates_completed",
            jsonEncode({'call_id': callID}));
      }
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        _remoteStream?.addTrack(track);
      });
    };

    socket.on("remote_ice_candidate", (data) async {
      var iceCandidateJson = jsonDecode(data) as Map<String, dynamic>;
      var iceCandidates = iceCandidateJson['ice_candidates'];
      for (var iceCandidate in iceCandidates) {
        print("ice_candidate arrived : " + iceCandidate.toString());
        var candidate = RTCIceCandidate(
          iceCandidate['candidate'],
          iceCandidate['sdpMid'],
          iceCandidate['sdpMLineIndex'],
        );
        await _peerConnection?.addCandidate(candidate);
      }
    });
  }

  // Future<void> acceptCall(
  //     RTCVideoRenderer remoteVideo, IO.Socket socket, String callID) async {
  //   print('Create PeerConnection with configuration: $_configuration');
  //   _peerConnection = await createPeerConnection(_configuration);

  //   registerPeerConnectionListeners();

  //   _localStream?.getTracks().forEach((track) {
  //     print("add local track: $track");
  //     _peerConnection?.addTrack(track, _localStream!);
  //   });

  //   _peerConnection?.onTrack = (RTCTrackEvent event) {
  //     print('Got remote track: ${event.streams[0]}');
  //     event.streams[0].getTracks().forEach((track) {
  //       print('Add a track to the remoteStream: $track');
  //       _remoteStream?.addTrack(track);
  //     });
  //   };

  //   _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
  //     if (candidate == null) {
  //       print('onIceCandidate: complete!');
  //       return;
  //     }
  //     print('Got candidate: ${candidate.toMap()}');
  //     socket.emit('callee_ice_candidate', jsonEncode(candidate.toMap()));
  //   };

  //   socket.on("offer", (data) {
  //     print("offer: " + data.toString());
  //     var offer = RTCSessionDescription(
  //       data['sdp'],
  //       data['type'],
  //     );

  //     print("Someone tried to connect");
  //     _peerConnection?.setRemoteDescription(offer);
  //     _peerConnection!.createAnswer().then((value) => {
  //           _peerConnection!.setLocalDescription(value),
  //           print("answer: ${value.type}"),
  //           sleep(Duration(seconds: 5)),
  //           socket.emit('answer',
  //               Signal(type: SignalType.answer, sdp: value.sdp!).toJSON())
  //         });
  //   });

  //   socket.emit('signaling', '');

  //   socket.on("ice_candidate", (data) async {
  //     print("ice_candidate: " + data.toString());
  //     var _data = jsonDecode(data) as Map<String, dynamic>;
  //     var candidate = RTCIceCandidate(
  //       _data['candidate'],
  //       _data['sdpMid'],
  //       _data['sdpMLineIndex'],
  //     );
  //     print("candidates): ${candidate.toMap()}");
  //     await _peerConnection?.addCandidate(candidate);
  //   });
  // }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': false});

    localVideo.srcObject = stream;
    _localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  // Future<void> hangUp(RTCVideoRenderer localVideo) async {
  //   List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
  //   tracks.forEach((track) {
  //     track.stop();
  //   });

  //   if (remoteStream != null) {
  //     remoteStream!.getTracks().forEach((track) => track.stop());
  //   }
  //   if (peerConnection != null) peerConnection!.close();

  //   if (roomId != null) {
  //     var db = FirebaseFirestore.instance;
  //     var roomRef = db.collection('rooms').doc(roomId);
  //     var calleeCandidates = await roomRef.collection('calleeCandidates').get();
  //     calleeCandidates.docs.forEach((document) => document.reference.delete());

  //     var callerCandidates = await roomRef.collection('callerCandidates').get();
  //     callerCandidates.docs.forEach((document) => document.reference.delete());

  //     await roomRef.delete();
  //   }

  //   localStream!.dispose();
  //   remoteStream?.dispose();
  // }

  void registerPeerConnectionListeners() {
    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    _peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      _remoteStream = stream;
    };
  }
}
