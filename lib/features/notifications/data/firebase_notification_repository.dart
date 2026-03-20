import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/firestore_error_utils.dart';
import '../../shared/domain/models/app_notification.dart';
import '../domain/repositories/notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseNotificationRepository(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> _notifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> _devices(String userId) {
    return _firestore.collection('users').doc(userId).collection('devices');
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) async* {
    try {
      yield* _notifications(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
      return;
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'notifications.watchNotifications',
        error: error,
        stackTrace: stackTrace,
      );

      if (error.code != 'failed-precondition') {
        rethrow;
      }
    }

    yield* _notifications(userId).snapshots().map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    try {
      final snapshot = await _notifications(
        userId,
      ).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(_fromDoc).toList();
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'notifications.fetchNotifications',
        error: error,
        stackTrace: stackTrace,
      );
      if (error.code != 'failed-precondition') {
        rethrow;
      }
      final fallbackSnapshot = await _notifications(userId).get();
      final items = fallbackSnapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId != notification.userId) {
      developer.log(
        'Skipping client-side notification create for ${notification.userId}. Use Cloud Functions for cross-user notifications.',
      );
      return;
    }

    final docRef = notification.id.isEmpty
        ? _notifications(notification.userId).doc()
        : _notifications(notification.userId).doc(notification.id);

    try {
      await docRef.set({
        'type': notification.type,
        'title': notification.title,
        'body': notification.body,
        'data': notification.data,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': notification.isRead,
      }, SetOptions(merge: true));
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'notifications.createNotification',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return _notifications(
      userId,
    ).doc(notificationId).set({'isRead': true}, SetOptions(merge: true));
  }

  @override
  Future<void> upsertDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) {
    return _devices(userId).doc(token).set({
      'token': token,
      'platform': platform,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  AppNotification _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();
    return AppNotification(
      id: doc.id,
      userId: doc.reference.parent.parent?.id ?? '',
      type: data['type'] as String? ?? 'activity',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      data: Map<String, dynamic>.from(
        data['data'] as Map? ?? const <String, dynamic>{},
      ),
      createdAt: createdAt,
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
