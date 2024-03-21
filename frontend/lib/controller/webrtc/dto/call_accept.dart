class CallAccept {
  CallAccept({required this.callID, required this.phoneNumber});

  String callID;
  String phoneNumber;

  toJSON() {
    return {'call_id': callID, 'phone_number': phoneNumber};
  }
}