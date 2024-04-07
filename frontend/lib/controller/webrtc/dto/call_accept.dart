class CallAccept {
  CallAccept({required this.callID});

  String callID;

  toJSON() {
    return {'call_id': callID};
  }
}
