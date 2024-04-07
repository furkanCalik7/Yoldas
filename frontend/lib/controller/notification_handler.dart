import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/notification_screen.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // TODO: call kit cantroller here
  print("Handling a background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");

  // notification test page - to be removed 
  navigationKey.currentState
      ?.pushNamed(NotificationScreen.routeName, arguments: message);
}

void handleMessage(RemoteMessage? message) {
  // TODO: Call kit controller here
  if (message == null) return;
  navigationKey.currentState
      ?.pushNamed(NotificationScreen.routeName, arguments: message);

  print("Handling a message: ${message?.messageId}");
  print("Title: ${message?.notification?.title}");
  print("Body: ${message?.notification?.body}");
  print("Payload: ${message?.data}");
}

void handleFrondgroundMessage(RemoteMessage remoteMessage) {
      final notification = remoteMessage.notification;
      if (notification == null) return;
      // TODO: notification behavior here when the app is awake
}

class NotificationHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> initializeNotifications(String phoneNumber) async {
    await _firebaseMessaging.requestPermission(provisional: true);
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");
    await saveTokenToDatabase(phoneNumber, fcmToken);
    initPushNotification();
  }

  Future<void> saveTokenToDatabase(String phoneNumber, String? token) async {
    var tokenRef = _db
        .collection('UserCollection')
        .doc(phoneNumber)
        .collection("fcm_tokens")
        .doc(token);
    await tokenRef.set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // If the app is not launch and the user launch app via notification,
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // hatirlamiyourm
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // If the app is in the background
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // If the app is open
    FirebaseMessaging.onMessage.listen((message) {
      handleFrondgroundMessage(message);      
    });
  }
}
