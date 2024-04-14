enum UserType { blind, volunteer }

String userTypeToString(UserType userType) {
  return userType == UserType.volunteer ? "volunteer" : "blind";
}

UserType? stringToUserType(String userType) {
  if (userType == "N/A") {
    return null;
  }
  return userType == "volunteer" ? UserType.volunteer : UserType.blind;
}
