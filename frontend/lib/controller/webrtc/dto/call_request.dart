class CallRequest {
  CallRequest({required this.type});

  String type;

  toJSON() {
    return {
      'type': type,
    };
  }
}
