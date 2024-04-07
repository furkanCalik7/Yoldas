import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/webrtc/dto/call_accept.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:http/http.dart' as http;

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

  Future<void> startCall(RTCVideoRenderer remoteRenderer, String type) async {
    String accessToken =
        await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

    print('(debug) Create PeerConnection with configuration: $configuration');

    CallRequest callRequest = CallRequest(type: type);

    final response = await ApiManager.post(
      path: "/calls/call",
      bearerToken: accessToken,
      body: callRequest.toJSON(),
    );

    var callJson = jsonDecode(response.body);
    var callId = callJson["call_id"];
    DocumentReference roomRef = callCollection.doc(callId);

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      print("(debug) Add local track: $track");
      peerConnection?.addTrack(track, localStream!);
    });

    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('(debug) Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('(debug) Created offer: $offer');

    var roomSnapshot = await roomRef.get();
    var data = roomSnapshot.data() as Map<String, dynamic>;
    data['caller']['signal'] = offer.toMap();
    await roomRef.update(data);
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

          print("(debug) Someone tried to connect: ${answer.toMap()}");
          await peerConnection?.setRemoteDescription(answer);
        }
      }
    });
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

  Future<void> acceptCall(RTCVideoRenderer remoteVideo, String roomId) async {
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
    );

    http.Response response = await ApiManager.post(
      path: "/calls/call/accept",
      bearerToken: await storage.read(key: "access_token"),
      body: callAccept.toJSON(),
    );

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
    });

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
