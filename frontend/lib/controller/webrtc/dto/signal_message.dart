import 'package:frontend/controller/webrtc/dto/signal.dart';

class SignalMessage {
  SignalMessage({required this.callID, required this.signal});

  late String callID;
  late Signal signal;

  toJSON() {
    return {"call_id": callID, "signal": signal.toJSON()};
  }
}
