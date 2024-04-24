import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controller/webrtc/constants/call_status.dart';
import 'package:frontend/controller/webrtc/dto/call_accept.dart';
import 'package:frontend/controller/webrtc/dto/call_accept_details_response.dart';
import 'package:frontend/controller/webrtc/dto/call_hangup.dart';
import 'package:frontend/controller/webrtc/dto/call_request.dart';
import 'package:frontend/controller/webrtc/dto/call_request_response.dart';
import 'package:frontend/pages/evaluation_page.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';

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
  Function(String) updateCalleeName;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  late CollectionReference callCollection;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? callId;
  late BuildContext context;

  // Subsciptions
  StreamSubscription<DocumentSnapshot<Object?>>? answerSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      calleeCandidatesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      callerCandidatesSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? hangupSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? calleeSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? offerSubscription;

  WebRTCController({required this.updateCalleeName}) {
    callCollection = db.collection('CallCollection');
  }

  Future<void> startCall(
      RTCVideoRenderer remoteRenderer, String call_id) async {
    String accessToken =
        SecureStorageManager.readFromCache(key: StorageKey.access_token) ??
            await SecureStorageManager.read(key: StorageKey.access_token) ??
            "N/A";

    print('(debug) Create PeerConnection with configuration: $configuration');
    callId = call_id;
    DocumentReference callRef = callCollection.doc(call_id);

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();
    print("local stream $localStream");
    localStream?.getTracks().forEach((track) {
      print("(debug) Add local track: $track");
      peerConnection?.addTrack(track, localStream!);
    });

    var callerCandidatesCollection = callRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('(debug) Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('(debug) Created offer: $offer');

    var roomSnapshot = await callRef.get();
    var data = roomSnapshot.data() as Map<String, dynamic>;
    data['caller']['signal'] = offer.toMap();
    await callRef.update(data);
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('(debug) Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('(debug) Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    answerSubscription = callRef.snapshots().listen((snapshot) async {
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
    calleeCandidatesSubscription =
        callRef.collection('calleeCandidates').snapshots().listen((snapshot) {
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
    // TODO: simdilik boyle birakiyorum ama bu acaba callee nin adimi olmali yoksa baska static bi seymi

    calleeSubscription = callRef.snapshots().listen((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data["callee"] != null) {
        print("(debug) update callee ${data['callee']}");
        updateCalleeName(data['callee']['name']);
      }
    });
    _registerFirestoreListeners();
  }

  Future<CallAcceptDetailsResponse> acceptCall(
      RTCVideoRenderer remoteVideo, String roomId) async {
    DocumentReference callRef = callCollection.doc(roomId);
    callId = roomId;

    print('(debug) Create PeerConnection with configuration: $configuration');
    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var calleeCandidatesCollection = callRef.collection('calleeCandidates');
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

    CallReject callAccept = CallReject(
      callID: roomId,
    );

    final response = await ApiManager.post(
      path: "/calls/call/accept_details",
      bearerToken: await storage.read(key: "access_token"),
      body: callAccept.toJSON(),
    );

    // offerSubscription = callRef.snapshots().listen((snapshot) async {
    //   print('(debug) Got updated room: ${snapshot.data()}');
    //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    //   if (data['caller'] != null) {
    //     var offerData = data['caller']['signal'];
    //     if (peerConnection?.getRemoteDescription() != null &&
    //         offerData != null) {
    //       var answer = RTCSessionDescription(
    //         offerData['sdp'],
    //         offerData['type'],
    //       );




    //       await peerConnection?.setRemoteDescription(answer);
    //     }
    //   }
    // });

    var signal = jsonDecode(response.body)['signal'];
    CallAcceptDetailsResponse callAcceptResponse =
        CallAcceptDetailsResponse.fromJSON(jsonDecode(response.body));
    RTCSessionDescription offer = RTCSessionDescription(
      signal['sdp'],
      signal['type'],
    );

    var roomSnapshot = await callRef.get();
    var data = roomSnapshot.data() as Map<String, dynamic>;
    await peerConnection?.setRemoteDescription(offer);
    peerConnection?.createAnswer().then((answer) async {
      peerConnection?.setLocalDescription(answer);
      data["callee"]["signal"] = answer.toMap();
      await callRef.update(data);
    });

    // Listening for remote ICE candidates below
    callerCandidatesSubscription =
        callRef.collection('callerCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;
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
    calleeSubscription = callRef.snapshots().listen((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data["caller"] != null) {
        updateCalleeName(data['caller']['name']);
      }
    });
    _registerFirestoreListeners();
    return callAcceptResponse;
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp() async {
    disposeSubsciptions();
    if (callId == null) return;
    CallHangup callHangup = CallHangup(callId: callId!);

    final response = await ApiManager.post(
      path: "/calls/call/hangup",
      bearerToken: await storage.read(key: "access_token"),
      body: callHangup.toJSON(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to hang up call');
    }
  }

  Future<void> _closePeerConnection() async {
    List<MediaStreamTrack> tracks = localStream!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    var callRef = db.collection('CallCollection').doc(callId);
    var calleeCandidates = await callRef.collection('calleeCandidates').get();
    calleeCandidates.docs.forEach((document) => document.reference.delete());

    var callerCandidates = await callRef.collection('callerCandidates').get();
    callerCandidates.docs.forEach((document) => document.reference.delete());

    // TO delete the call from firestore
    // await callRef.delete();

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void disposeSubsciptions() {
    answerSubscription?.cancel();
    calleeCandidatesSubscription?.cancel();
    callerCandidatesSubscription?.cancel();
  }

  void switchVideo() async {
    if (localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await Helper.switchCamera(videoTrack);
  }

  Future<void> toggleVideo(bool isOn) async {
    for (var track in localStream!.getVideoTracks()) {
      track.enabled = isOn;
    }
  }

  Future<void> toggleAudio(bool isOn) async {
    for (var track in localStream!.getAudioTracks()) {
      track.enabled = isOn;
    }
  }

  Future<void> toogleSpeaker(bool isOn) async {
    for (var track in remoteStream!.getAudioTracks()) {
      track.enabled = isOn;
    }
  }

  Future<void> toggleTorch(bool isOn) async {
    if (localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final has = await videoTrack.hasTorch();
    if (has) {
      print('[TORCH] Current camera supports torch mode');
      await videoTrack.setTorch(isOn);
      print('[TORCH] Torch state is now ${isOn ? 'on' : 'off'}');
    } else {
      print('[TORCH] Current camera does not support torch mode');
    }
  }

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

  void setContext(BuildContext context) {
    this.context = context;
  }

  void _moveToNextScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => EvaluationPage(
                  callId: callId!,
                )),
        (route) => false);
    hangupSubscription?.cancel();
    calleeSubscription?.cancel();
  }

  void _registerFirestoreListeners() {
    hangupSubscription =
        callCollection.doc(callId).snapshots().listen((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (data["status"] == CallStatus.FINISHED) {
        _closePeerConnection();
        _moveToNextScreen();
      }
    });
  }

  void dispose() {
    disposeSubsciptions();
    _closePeerConnection();
    localStream?.dispose();
    remoteStream?.dispose();
  }
}
