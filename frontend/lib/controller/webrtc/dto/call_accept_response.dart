class CallAcceptResponse {
  bool isAccepted;

  CallAcceptResponse({
    required this.isAccepted,
  });

  factory CallAcceptResponse.fromJson(Map<String, dynamic> json) {
    return CallAcceptResponse(
      isAccepted: json['is_accepted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_accepted': isAccepted,
    };
  }
}
