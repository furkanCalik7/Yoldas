
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_webrtc/flutter_webrtc.dart";
import "package:frontend/controller/webrtc/dto/ice_candidate_message.dart";
import "package:frontend/utility/enum/call_user.dart";
import "package:socket_io_client/socket_io_client.dart" as io;

class IceCandidateHandler {
  String? callId;
  List<RTCIceCandidate?> iceCandidates = [];
  io.Socket socket;
  CallUser callUser;
  DocumentReference<Object?>? callDoc;

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

    callDoc!.collection('${callUser.name}_ice_candidates').add(candidate.toMap()); 


    // IceCandidateMessage iceCandidate =
    //     IceCandidateMessage(callID: callId!, iceCandidate: candidate);


    // Assuming `socket.emit` is a function to send data over the socket
    // socket.emit(
    //     '${callUser.name}_ice_candidate', jsonEncode(iceCandidate.toJSON()));
  }

  void setCallId(String id) {
    callId = id;
    callDoc = FirebaseFirestore.instance.collection('CallCollection').doc(callId);
    // Process any stored ICE candidates after receiving callId
    iceCandidates.forEach((candidate) {
      sendIceCandidate(candidate!);
    });
    // Clear stored ICE candidates after sending them
    iceCandidates.clear();
  }
}
