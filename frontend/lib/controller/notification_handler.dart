import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/notification_screen.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");

  navigationKey.currentState
      ?.pushNamed(NotificationScreen.routeName, arguments: message);
}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  navigationKey.currentState
      ?.pushNamed(NotificationScreen.routeName, arguments: message);

  print("Handling a message: ${message?.messageId}");
  print("Title: ${message?.notification?.title}");
  print("Body: ${message?.notification?.body}");
  print("Payload: ${message?.data}");
}

class NotificationHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  final _androidNotificationChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications(String phoneNumber) async {
    await _firebaseMessaging.requestPermission(provisional: true);
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");
    await saveTokenToDatabase(phoneNumber, fcmToken);
    initPushNotification();
    initLocalNotification();
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

  Future initLocalNotification() async {
    const iOs = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOs);

    await _localNotifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        if (payload == null) return;
        final message = RemoteMessage.fromMap(jsonDecode(payload));
        handleMessage(message);
      },
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidNotificationChannel);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      print("local notification");
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              _androidNotificationChannel.id, _androidNotificationChannel.name,
              channelDescription: _androidNotificationChannel.description,
              icon: '@drawable/ic_launcher'),
        ),
        payload: jsonEncode({message.toMap()}),
      );
    });
  }
}
