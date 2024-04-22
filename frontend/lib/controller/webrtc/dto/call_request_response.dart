class CallRequestResponse {
  CallRequestResponse({required this.callID});

  String callID;

  toJSON() {
    return {'call_id': callID};
  }

  factory CallRequestResponse.fromJSON(Map<String, dynamic> json) {
    return CallRequestResponse(
      callID: json['call_id'],
    );
  }
}
