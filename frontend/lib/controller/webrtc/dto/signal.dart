import 'package:frontend/util/enum/signal_type.dart';

class Signal {
  Signal({required this.type, required this.sdp});

  SignalType type;
  String sdp;

  toJSON() {
    return {'type': type.name, 'sdp': sdp};
  }
}
