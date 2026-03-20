import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/usecases/upsert_device_token.dart';

const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'swap_notifications',
  'Swap Notifications',
  description: 'General notifications for messages and marketplace activity.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final UpsertDeviceToken _upsertDeviceToken;

  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _isInitialized = false;
  bool _pushEnabled = false;
  String? _userId;

  PushNotificationService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required FlutterLocalNotificationsPlugin localNotifications,
    required UpsertDeviceToken upsertDeviceToken,
  }) : _messaging = messaging,
       _firestore = firestore,
       _localNotifications = localNotifications,
       _upsertDeviceToken = upsertDeviceToken;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await _initializeLocalNotifications();
      _foregroundMessageSub = FirebaseMessaging.onMessage.listen(
        _showForegroundNotification,
      );
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(
        _upsertTokenIfPossible,
      );
    } on MissingPluginException {
      // Running in environments without native plugin registration (tests/desktop).
    }
  }

  Future<bool> isPermissionGranted() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final status = settings.authorizationStatus;
      return status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;
    } on MissingPluginException {
      // Running in environments without native plugin registration (tests/desktop).
      return false;
    }
  }

  Future<bool> requestPermissionIfNeeded() async {
    try {
      if (await isPermissionGranted()) {
        return true;
      }
      await _requestPermissions();
      final granted = await isPermissionGranted();
      if (granted) {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _upsertTokenIfPossible(token);
        }
      }
      return granted;
    } on MissingPluginException {
      // Running in environments without native plugin registration (tests/desktop).
      return false;
    }
  }

  Future<void> requestNotificationsPermission() => requestPermissionIfNeeded();

  Future<void> setPushEnabled(bool enabled) async {
    _pushEnabled = enabled;
  }

  Future<void> syncCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _upsertTokenIfPossible(token);
    } on MissingPluginException {
      // Running in environments without native plugin registration (tests/desktop).
    }
  }

  Future<void> bindUser(String? userId) async {
    _userId = userId;
    if (!_isInitialized || userId == null || userId.isEmpty) {
      _pushEnabled = false;
      return;
    }
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      _pushEnabled = snapshot.data()?['pushEnabled'] as bool? ?? false;
      await syncCurrentToken();
    } on MissingPluginException {
      // Running in environments without native plugin registration (tests/desktop).
    } on FirebaseException {
      _pushEnabled = false;
    }
  }

  Future<void> dispose() async {
    await _foregroundMessageSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initializationSettings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_defaultChannel);
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _upsertTokenIfPossible(String token) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    await _upsertDeviceToken.call(
      userId: userId,
      token: token,
      platform: _platformName(),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_pushEnabled) {
      return;
    }
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null || body == null) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    final platform = defaultTargetPlatform;
    return switch (platform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}
