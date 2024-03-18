import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/config.dart';
import 'package:frontend/controller/webrtc/dto/call_accept.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/controller/webrtc/dto/signal.dart';
import 'package:frontend/controller/webrtc/dto/signal_message.dart';
import 'package:frontend/utility/enum/signal_type.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/controller/webrtc/utility/ice_candidate_handler.dart';
import 'package:frontend/utility/enum/call_user.dart';

typedef void StreamStateCallback(MediaStream stream);

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
  late CollectionReference callCollection;

  WebRTCController() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    callCollection = db.collection('CallCollection');
  }

  // TODO: Make type parameter enum
  Future<String> requestCall(
      RTCVideoRenderer remoteRenderer, io.Socket socket, String type) async {
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
    );

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

      callCollection
          .doc(callJson["call_id"])
          .collection('callee_ice_candidates')
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                change.doc.data() as Map<String, dynamic>;
            print('Got new remote ICE candidate: ${jsonEncode(data)}');
            _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });
      });

      // Stream<DocumentSnapshot> snapshot =  callStream.doc(callJson["call_id"]).snapshots();

      // callCollection.doc(callJson["call_id"]).snapshots().listen((snapshot) {
      //   var test = snapshot.data() as Map<String, dynamic>;
      //   print("test");

      // snapshot.docChanges.forEach((change) {
      // // if (change.type == DocumentChangeType.added) {
      // //   Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
      // //   print('Got new remote ICE candidate: ${jsonEncode(data)}');
      // //   peerConnection!.addCandidate(
      // //     RTCIceCandidate(
      // //       data['candidate'],
      // //       data['sdpMid'],
      // //       data['sdpMLineIndex'],
      // //     ),
      // //   );
      // }
      // });

      // _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      //   if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      //     print("caller_ice_candidates_completed");
      //     socket.emit("caller_ice_candidates_completed",
      //         jsonEncode({'call_id': callJson["call_id"]}));
      //   }
      // };
      iceCandidateHandler.setCallId(callJson["call_id"]);

      _sendPeerConnection(
          remoteRenderer, socket, CallUser.caller, callJson["call_id"]);

      completer.complete(callJson["call_id"]);
    });
    return completer.future;
  }

  Future<void> acceptCall(
      RTCVideoRenderer remoteRenderer, io.Socket socket, String callID) async {
    CallAccept callAccept = CallAccept(
        callID: callID,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A");

    _peerConnection = await createPeerConnection(_configuration);
    IceCandidateHandler iceCandidateHandler =
        IceCandidateHandler(socket: socket, callUser: CallUser.callee);

    _peerConnection?.onIceCandidate = iceCandidateHandler.handleIceCandidate;
    _sendPeerConnection(remoteRenderer, socket, CallUser.callee, callID);

    // _peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
    //   if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
    //     print("callee_ice_candidates_completed");
    //     socket.emit(
    //         "callee_ice_candidates_completed", jsonEncode({'call_id': callID}));
    //   }
    // };

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

      callCollection
          .doc(callID)
          .collection('caller_ice_candidates')
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          _peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });

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
      io.Socket socket, CallUser callUser, String callID) async {
    print(
        '$callUser: Create PeerConnection with configuration: $_configuration');
    print("CallID: $callID");

    registerPeerConnectionListeners();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        _remoteStream?.addTrack(track);
      });
    };

    // socket.on("remote_ice_candidate", (data) async {
    //   var iceCandidateJson = jsonDecode(data) as Map<String, dynamic>;
    //   var iceCandidates = iceCandidateJson['ice_candidates'];
    //   for (var iceCandidate in iceCandidates) {
    //     print("ice_candidate arrived : " + iceCandidate.toString());
    //     var candidate = RTCIceCandidate(
    //       iceCandidate['candidate'],
    //       iceCandidate['sdpMid'],
    //       iceCandidate['sdpMLineIndex'],
    //     );
    //     await _peerConnection?.addCandidate(candidate);
    //   }
    // });
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
