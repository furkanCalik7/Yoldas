class CallHangup {
  String callId;

  CallHangup({
    required this.callId,
  });

  factory CallHangup.fromJson(Map<String, dynamic> json) {
    return CallHangup(
      callId: json['call_id'],
    );
  }

  toJSON() {
    return {
      'call_id': callId,
    };
  }
}
