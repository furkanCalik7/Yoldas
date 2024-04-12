class CallAcceptResponse {
  CallAcceptResponse({required this.callerName, required this.callID});

  String callerName;
  String callID;

  toJSON() {
    return {'caller_name': callerName, 'call_id': callID};
  }

  factory CallAcceptResponse.fromJSON(Map<String, dynamic> json) {
    return CallAcceptResponse(
      callerName: json['caller_name'],
      callID: json['call_id'],
    );
  }
}
