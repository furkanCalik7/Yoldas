import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/controller/webrtc/dto/call_accept.dart';
import 'package:frontend/controller/webrtc/dto/call_accept_response.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/call_main_frame.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:uuid/uuid.dart';

String? currentUuid;
String? lastCallId;

Future<void> showCallkitIncoming(String callId) async {
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
    extra: <String, dynamic>{'callId': callId},
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
  print("(notification) handleBackgroundMEssage : ${message.data['call_id']}");
  if (message.data["call_id"] == lastCallId) return;
  lastCallId = message.data["call_id"];
  await showCallkitIncoming(message.data["call_id"]);
}

void handleMessage(RemoteMessage? message) async {
//   if (message?.data["call_id"] == lastCallId) return;
//   lastCallId = message?.data["call_id"];
//   await showCallkitIncoming(message?.data["call_id"]);
}

void handleFrondgroundMessage(RemoteMessage message) async {
  print("(notification) handleFrondgroundMessage: ${message.data['call_id']}");
  if (message.data["call_id"] == lastCallId) return;
  lastCallId = message.data["call_id"];
  await showCallkitIncoming(message.data["call_id"]);
}

Future<CallAcceptResponse> handleCallAccept(String callId) async {
  String accessToken =
      await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

  CallReject callAccept = CallReject(
    callID: callId,
  );

  final response = await ApiManager.post(
    path: "/calls/call/accept",
    bearerToken: accessToken,
    body: callAccept.toJSON(),
  );

  return CallAcceptResponse.fromJson(jsonDecode(response.body));
}

Future<void> handleCallReject(String callId) async {
  String accessToken =
      await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A";

  CallReject callReject = CallReject(
    callID: callId,
  );

  await ApiManager.post(
    path: "/calls/call/reject",
    bearerToken: accessToken,
    body: callReject.toJSON(),
  );
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
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
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

  void initPushNotification() {
    print("Flutter callkit callback is initialized");
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      print("callkit event: $event");
      if (event == null) return;
      String callId = event.body["extra"]["callId"];

      switch (event.event) {
        case Event.actionCallIncoming:
          break;
        case Event.actionCallStart:
          break;
        case Event.actionCallAccept:
          handleCallAccept(callId).then(
            (callAccept) {
              if (callAccept.isAccepted) {
                print("Call is accepted");
                navigationKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => CallMainFrame(
                        callId: callId,
                        callActionType: "accept",
                      ),
                    ),
                    ModalRoute.withName('/onboarding'));
              } else {
                // TODO: show it is already accepted thank you
              }
            },
          );
          flutterLocalNotificationsPlugin.cancelAll();
          break;
        case Event.actionCallDecline:
          handleCallReject(callId);
          flutterLocalNotificationsPlugin.cancelAll();
          break;
        case Event.actionCallEnded:
          break;
        case Event.actionCallTimeout:
          flutterLocalNotificationsPlugin.cancelAll();
          break;
        case Event.actionCallCallback:
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
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      handleFrondgroundMessage(message);
    });
  }
}
