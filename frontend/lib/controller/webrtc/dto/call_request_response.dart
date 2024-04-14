class CallRequestResponse {
  CallRequestResponse({required this.calleeName, required this.callID});

  String calleeName;
  String callID;

  toJSON() {
    return {'callee_name': calleeName, 'call_id': callID};
  }

  factory CallRequestResponse.fromJSON(Map<String, dynamic> json) {
    return CallRequestResponse(
      calleeName: json['callee_name'],
      callID: json['call_id'],
    );
  }
}
