import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  late CollectionReference callCollection;

  WebRTCController() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    callCollection = db.collection('CallCollection');
  }

  Future<void> createRoom(
      RTCVideoRenderer remoteRenderer, String type) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    print('(debug) Create PeerConnection with configuration: $configuration');
    // Signal signal = Signal(type: SignalType.offer, sdp: offer.sdp!);

    CallRequest callRequest = CallRequest(
        type: type,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A");

    http.Response test = await http.post(
        Uri.parse(
          "$API_URL/calls/call",
        ),
        body: jsonEncode(callRequest.toJSON()),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
        });
    var response = test.body;

    var callJson = jsonDecode(response);
    var callId = callJson["call_id"];
    DocumentReference roomRef = callCollection.doc(callId);

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      print("(debug) Add local track: $track");
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('(debug) Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('(debug) Created offer: $offer');

    // Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    var roomSnapshot = await roomRef.get();
    var data = roomSnapshot.data() as Map<String, dynamic>;
    data['caller']['signal'] = offer.toMap();
    await roomRef.update(data);
    // await roomRef.set(roomWithOffer);
    // var roomId = roomRef.id;
    // print('New room created with SDK offer. Room ID: $roomId');
    // currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('(debug) Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('(debug) Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    roomRef.snapshots().listen((snapshot) async {
      print('(debug) Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data['callee'] != null) {
        var answerData = data['callee']['signal'];
        if (peerConnection?.getRemoteDescription() != null &&
            answerData != null) {
          var answer = RTCSessionDescription(
            answerData['sdp'],
            answerData['type'],
          );

          // await Future.delayed(Duration(seconds: 2));
          // sleep(Duration(seconds: 2));
          print("(debug) Someone tried to connect: ${answer.toMap()}");
          await peerConnection?.setRemoteDescription(answer);
        }
      }
    });

    // socket.on("answer_to_caller", (data) {
    //   var answerJson = jsonDecode(data) as Map<String, dynamic>;
    //   var signal = answerJson['signal'];
    //   var answer = RTCSessionDescription(
    //     signal['sdp'],
    //     signal['type'],
    //   );
    //   print("Someone tried to connect");
    //   peerConnection?.setRemoteDescription(answer);
    // });

    // Listening for remote session description below
    // roomRef.snapshots().listen((snapshot) async {
    //   print('Got updated room: ${snapshot.data()}');

    //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    //   if (peerConnection?.getRemoteDescription() != null &&
    //       data['answer'] != null) {
    //     var answer = RTCSessionDescription(
    //       data['answer']['sdp'],
    //       data['answer']['type'],
    //     );

    //     print("Someone tried to connect");
    //     await peerConnection?.setRemoteDescription(answer);
    //   }
    // });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('(debug) Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
  }

  Future<void> joinRoom(
      RTCVideoRenderer remoteVideo, String roomId) async {
    DocumentReference roomRef = callCollection.doc(roomId);

    print('(debug) Create PeerConnection with configuration: $configuration');
    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        print('(debug) onIceCandidate: complete!');
        return;
      }
      print('(debug) onIceCandidate: ${candidate.toMap()}');
      calleeCandidatesCollection.add(candidate.toMap());
    };
    // Code for collecting ICE candidate above

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('(debug) Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('(debug) Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };

    CallAccept callAccept = CallAccept(
        callID: roomId,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A");

    http.Response response = await http.post(
        Uri.parse(
          "$API_URL/calls/call/accept",
        ),
        body: jsonEncode(callAccept.toJSON()),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
        });

    var signal = jsonDecode(response.body)['offer'];
    RTCSessionDescription offer = RTCSessionDescription(
      signal['sdp'],
      signal['type'],
    );

    var roomSnapshot = await roomRef.get();
    var data = roomSnapshot.data() as Map<String, dynamic>;
    await peerConnection?.setRemoteDescription(offer);
    peerConnection?.createAnswer().then((answer) async {
      peerConnection?.setLocalDescription(answer);
      data["callee"]["signal"] = answer.toMap();
      await roomRef.update(data);

      // Signal signal = Signal(type: SignalType.answer, sdp: value.sdp!);
      // SignalMessage signalMessage =
      //     SignalMessage(callID: roomId, signal: signal);
      // socket.emit("answer_signal", jsonEncode(signalMessage.toJSON()));
    });

    // Code for creating SDP answer below
    // var data = roomSnapshot.data() as Map<String, dynamic>;
    // print('Got offer $data');
    // var offer = data['offer'];
    // await peerConnection?.setRemoteDescription(
    //   RTCSessionDescription(offer['sdp'], offer['type']),
    // );
    // var answer = await peerConnection!.createAnswer();
    // print('Created Answer $answer');

    // await peerConnection!.setLocalDescription(answer);

    // Map<String, dynamic> roomWithAnswer = {
    //   'answer': {'type': answer.type, 'sdp': answer.sdp}
    // };

    // await roomRef.update(roomWithAnswer);
    // Finished creating SDP answer

    // Listening for remote ICE candidates below
    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;
        print(data);
        print('(debug) Got new remote ICE candidate: $data');
        peerConnection!.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      });
    });
  }

  // Future<String> requestCall(
  //     RTCVideoRenderer remoteRenderer, io.Socket socket, String type) async {
  //   _peerConnection = await createPeerConnection(_configuration);
  //   RTCSessionDescription offer = await _peerConnection!.createOffer();
  //   if (offer.sdp == null) throw Exception("offer.sdp is null");
  //   await _peerConnection!.setLocalDescription(offer);
  //   Signal signal = Signal(type: SignalType.offer, sdp: offer.sdp!);
  //   IceCandidateHandler iceCandidateHandler =
  //       IceCandidateHandler(socket: socket, callUser: CallUser.caller);
  //   _peerConnection?.onIceCandidate = iceCandidateHandler.handleIceCandidate;

  //   socket.on("answer_to_caller", (data) {
  //     var answerJson = jsonDecode(data) as Map<String, dynamic>;
  //     var signal = answerJson['signal'];
  //     var answer = RTCSessionDescription(
  //       signal['sdp'],
  //       signal['type'],
  //     );
  //     print("Someone tried to connect");
  //     _peerConnection?.setRemoteDescription(answer);
  //   });

  //   CallRequest callRequest = CallRequest(
  //       type: type,
  //       phoneNumber: await storage.read(key: "phone_number") ?? "N/A",
  //       signal: signal);

  //   Completer<String> completer = Completer<String>();
  //   http.post(
  //       Uri.parse(
  //         "$API_URL/calls/call",
  //       ),
  //       body: jsonEncode(callRequest.toJSON()),
  //       headers: {
  //         "Content-Type": "application/json",
  //         'Authorization': 'Bearer ${await storage.read(key: "access_token")}'
  //       }).then((value) {
  //     var callJson = jsonDecode(value.body);

  //     callCollection
  //         .doc(callJson["call_id"])
  //         .collection('callee_ice_candidates')
  //         .snapshots()
  //         .listen((snapshot) {
  //       snapshot.docChanges.forEach((change) {
  //         if (change.type == DocumentChangeType.added) {
  //           Map<String, dynamic> data =
  //               change.doc.data() as Map<String, dynamic>;
  //           print('Got new remote ICE candidate: ${jsonEncode(data)}');
  //           _peerConnection!.addCandidate(
  //             RTCIceCandidate(
  //               data['candidate'],
  //               data['sdpMid'],
  //               data['sdpMLineIndex'],
  //             ),
  //           );
  //         }
  //       });
  //     });

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

  Future<void> acceptCall(
      RTCVideoRenderer remoteRenderer, io.Socket socket, String callID) async {
    CallAccept callAccept = CallAccept(
        callID: callID,
        phoneNumber: await storage.read(key: "phone_number") ?? "N/A");

    peerConnection = await createPeerConnection(configuration);
    IceCandidateHandler iceCandidateHandler =
        IceCandidateHandler(socket: socket, callUser: CallUser.callee);

    peerConnection?.onIceCandidate = iceCandidateHandler.handleIceCandidate;
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
          peerConnection!.addCandidate(
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
      peerConnection?.setRemoteDescription(offer);
      peerConnection?.createAnswer().then((value) {
        peerConnection?.setLocalDescription(value);
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
        '$callUser: Create PeerConnection with configuration: $configuration');
    print("CallID: $callID");

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
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
    localStream = stream;

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
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('(debug) ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('(debug) Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('(debug) Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('(debug) ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
