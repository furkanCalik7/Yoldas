import 'package:flutter_webrtc/flutter_webrtc.dart';

class IceCandidateMessage {
  IceCandidateMessage({required this.callID, required this.iceCandidate});

  late String callID;
  RTCIceCandidate? iceCandidate;
  toJSON() {
    return {'call_id': callID, 'ice_candidate': iceCandidate!.toMap()};
  }
}
