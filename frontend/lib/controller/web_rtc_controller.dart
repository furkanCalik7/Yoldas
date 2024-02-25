import 'dart:convert';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef void StreamStateCallback(MediaStream stream);

enum SignalType { offer, answer }

class CallRequest {
  CallRequest({required this.type, required this.signal});

  Signal signal;
  String type;

  toJSON() {
    return {'type': type, 'signal': signal.toJSON()};
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

  Future<void> requestCall(
      RTCVideoRenderer remoteRenderer, IO.Socket socket) async {
    print('Create PeerConnection with configuration: $_configuration');

    _peerConnection = await createPeerConnection(_configuration);
    registerPeerConnectionListeners();

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    print("offer: ${offer.type}");

    if (offer.sdp != null) {
      CallRequest callRequest = CallRequest(
          type: "fast",
          signal: Signal(type: SignalType.offer, sdp: offer.sdp!));

      // http.post(
      //     Uri.parse(
      //       "$API_URL/calls/call/0",
      //     ),
      //     body: jsonEncode(callRequest.toJSON()),
      //     headers: {
      //       "Content-Type": "application/json",
      //       'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
      //     }).then((value) => print(value.body));
      // TODO: testing if it is better to use http or socket

      socket.emit("call_request", jsonEncode(callRequest.toJSON()));

      socket.on("call_request_response", (data) {
        print("data");
        _localStream?.getTracks().forEach((track) {
          _peerConnection?.addTrack(track, _localStream!);
        });

        _peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
          if (candidate == null) {
            print('onIceCandidate: complete!');
            return;
          }

          print('Got candidate: ${candidate.toMap()}');
          // TODO: after designing signal mechanisim
          socket.emit('ice_candidate', jsonEncode(candidate.toMap()));
        };
        // Finish Code for collecting ICE candidate

        _peerConnection?.onTrack = (RTCTrackEvent event) {
          print('Got remote track: ${event.streams[0]}');
          event.streams[0].getTracks().forEach((track) {
            print('Add a track to the remoteStream $track');
            _remoteStream?.addTrack(track);
          });
        };

        socket.on("answer", (data) {
          print("answer: " + data.toString());
          var answer = RTCSessionDescription(
            data['sdp'],
            data['type'],
          );
          print("Someone tried to connect");
          _peerConnection?.setRemoteDescription(answer);
        });

        socket.on("ice_candidate", (data) async {
          print("icecandidate: " + data.toString());
          var _data = jsonDecode(data) as Map<String, dynamic>;
          var candidate = RTCIceCandidate(
            _data['candidate'],
            _data['sdpMid'],
            _data['sdpMLineIndex'],
          );
          await _peerConnection?.addCandidate(candidate);
        });
      });
    } else {
      print("offer.sdp is null");
    }
  }

  Future<void> acceptCall(
      RTCVideoRenderer remoteVideo, IO.Socket socket) async {
    print('Create PeerConnection with configuration: $_configuration');
    _peerConnection = await createPeerConnection(_configuration);

    registerPeerConnectionListeners();

    _localStream?.getTracks().forEach((track) {
      print("add local track: $track");
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('Got candidate: ${candidate.toMap()}');
      socket.emit('callee_ice_candidate', jsonEncode(candidate.toMap()));
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        _remoteStream?.addTrack(track);
      });
    };

    socket.on("offer", (data) {
      print("offer: " + data.toString());
      var offer = RTCSessionDescription(
        data['sdp'],
        data['type'],
      );

      print("Someone tried to connect");
      _peerConnection?.setRemoteDescription(offer);
      _peerConnection!.createAnswer().then((value) => {
            _peerConnection!.setLocalDescription(value),
            print("answer: ${value.type}"),
            sleep(Duration(seconds: 5)),
            socket.emit('answer',
                Signal(type: SignalType.answer, sdp: value.sdp!).toJSON())
          });
    });

    socket.emit('signaling', '');

    socket.on("ice_candidate", (data) async {
      print("ice_candidate: " + data.toString());
      var _data = jsonDecode(data) as Map<String, dynamic>;
      var candidate = RTCIceCandidate(
        _data['candidate'],
        _data['sdpMid'],
        _data['sdpMLineIndex'],
      );
      print("candidates): ${candidate.toMap()}");
      await _peerConnection?.addCandidate(candidate);
    });
  }

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
