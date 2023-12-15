enum UserType { blind, volunteer }

String userTypeToString(UserType userType) {
  return userType == UserType.volunteer ? "volunteer" : "blind";
}
