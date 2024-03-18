

class CallRequest {
  CallRequest(
      {required this.type, required this.phoneNumber});

  String type;
  String phoneNumber;
  

  toJSON() {
    return {
      'type': type,
      "phone_number": phoneNumber
    };
  }
}