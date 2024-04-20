import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

String? currentUuid;

Future<void> showCallkitIncoming() async {
  final uuid = Uuid().v4();
  currentUuid = uuid;

  final params = CallKitParams(
    id: uuid,
    nameCaller: '     Görme Engelli birisinin yardımınıza ihtiyacı var.',
    appName: 'Callkit',
    avatar: 'assets/profile.jpg',
    handle: 'Görme Engelli birisinin yardımınıza ihtiyacı var.',
    type: 1,
    duration: 10000,
    textAccept: 'Kabul et',
    textDecline: 'Reddet',
    missedCallNotification: const NotificationParams(
      showNotification: false,
      isShowCallback: false,
      subtitle: 'Cevapsız çağrı',
      callbackText: 'Geri ara',
    ),
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#1C1C1C',
      backgroundUrl: 'assets/test.jpg',
      actionColor: '#4CAF50',
      textColor: '#ffffff',
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // TODO: call kit cantroller here
  print("Handling a background message: ${message.messageId}");
  print("Payload: ${message.data}");
  await showCallkitIncoming();
}

void handleMessage(RemoteMessage? message) async {
  // TODO: Call kit controller here

  print("Handling a message: ${message?.messageId}");
  print("Payload: ${message?.data}");
}

void handleFrondgroundMessage(RemoteMessage remoteMessage) async {
  print("Handling a foreground message: ${remoteMessage.messageId}");
  print("Handling a foreground message: ${remoteMessage.data}");
  await showCallkitIncoming();
  // TODO: notification behavior here when the app is awake
}

class NotificationHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      alert: false,
      badge: false,
      sound: false,
    );

    // If the app is not launch and the user launch app via notification,
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // If the app is in the background
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // If the app is open
    FirebaseMessaging.onMessage.listen((message) {
      handleFrondgroundMessage(message);
    });

    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      print("Event: ${event?.event}");
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          print("Call accepted");
          break;
        case Event.actionCallDecline:
          // TODO: declined an incoming call
          print("Call declined");
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          // cancel the notification
          flutterLocalNotificationsPlugin.cancelAll();
          print("Notification canceled");

          // TODO: inform server that the call is missed

          break;
        case Event.actionCallCallback:
          // only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // only iOS
          break;
        case Event.actionCallToggleMute:
          // only iOS
          break;
        case Event.actionCallToggleDmtf:
          // only iOS
          break;
        case Event.actionCallToggleGroup:
          // only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // only iOS
          break;
        case Event.actionCallCustom:
          // for custom action
          break;
      }
    });
  }
}
