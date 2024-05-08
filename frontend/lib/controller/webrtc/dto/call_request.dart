class CallRequest {
  CallRequest({
    required this.isQuickCall,
    this.category,
    this.isConsultancyCall,
  });

  bool isQuickCall;
  String? category;
  bool? isConsultancyCall;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isQuickCall'] = isQuickCall;
    if (category != null) data['category'] = category;
    if (isConsultancyCall != null) {
      data['isConsultancyCall'] = isConsultancyCall;
    }
    return data;
  }
  factory CallRequest.fromJson(Map<String, dynamic> json) {
    return CallRequest(
      isQuickCall: json['isQuickCall'] as bool,
      category: json['category'] as String?,
      isConsultancyCall: json['isConsultancyCall'] as bool?,
    );
  }
}
