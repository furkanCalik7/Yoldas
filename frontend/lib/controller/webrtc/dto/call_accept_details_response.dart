class CallAcceptDetailsResponse {
  CallAcceptDetailsResponse({required this.callID});

  String callID;

  toJSON() {
    return {'call_id': callID};
  }

  factory CallAcceptDetailsResponse.fromJSON(Map<String, dynamic> json) {
    return CallAcceptDetailsResponse(
      callID: json['call_id'],
    );
  }
}
