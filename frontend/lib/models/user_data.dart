class UserData {
  final String name;
  final String password;
  final String phoneNumber;
  final String accessToken;
  final String role;
  final String tokenType;
  final List<String> abilities;
  final bool isConsultant;
  final bool isActive;

  UserData({
    this.name = "",
    this.accessToken="",
    this.role="",
    this.abilities= const [],
    this.tokenType = "",
    this.isConsultant=false,
    this.isActive=true,
    required this.password,
    required this.phoneNumber,}
);
}
