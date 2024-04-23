class CallAcceptDetailsResponse {
  CallAcceptDetailsResponse({required this.callerName, required this.callID});

  String callerName;
  String callID;

  toJSON() {
    return {'caller_name': callerName, 'call_id': callID};
  }

  factory CallAcceptDetailsResponse.fromJSON(Map<String, dynamic> json) {
    return CallAcceptDetailsResponse(
      callerName: json['caller_name'],
      callID: json['call_id'],
    );
  }
}
