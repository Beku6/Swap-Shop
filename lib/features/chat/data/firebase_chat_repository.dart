import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/observability/app_analytics.dart';
import '../../../core/utils/firestore_error_utils.dart';
import '../../notifications/domain/repositories/notification_repository.dart';
import '../../shared/domain/models/app_notification.dart';
import '../../shared/domain/models/chat_thread.dart';
import '../../shared/domain/models/message.dart';
import '../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;
  final AppAnalytics _analytics;

  FirebaseChatRepository(
    this._firestore,
    this._notificationRepository,
    this._analytics,
  );

  CollectionReference<Map<String, dynamic>> get _threads =>
      _firestore.collection('chatThreads');

  CollectionReference<Map<String, dynamic>> _userThreads(String userId) =>
      _firestore.collection('users').doc(userId).collection('chatThreads');

  CollectionReference<Map<String, dynamic>> _messages(String threadId) =>
      _threads.doc(threadId).collection('messages');

  @override
  Stream<List<ChatThread>> watchThreads(String userId) async* {
    try {
      yield* _userThreads(userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_threadFromDoc).toList());
      return;
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'chat.watchThreads',
        error: error,
        stackTrace: stackTrace,
      );

      if (error.code != 'failed-precondition') {
        rethrow;
      }
    }

    // Fallback for index setup delays.
    yield* _userThreads(userId).snapshots().map((snapshot) {
      final threads = snapshot.docs.map(_threadFromDoc).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return threads;
    });
  }

  @override
  Stream<List<Message>> watchMessages(String threadId) async* {
    if (threadId.isEmpty) {
      yield const <Message>[];
      return;
    }
    try {
      yield* _messages(threadId)
          .orderBy('sentAt', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _messageFromDoc(doc, threadId))
                .toList(),
          );
      return;
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'chat.watchMessages',
        error: error,
        stackTrace: stackTrace,
      );

      if (error.code != 'failed-precondition') {
        rethrow;
      }
    }

    yield* _messages(threadId).snapshots().map((snapshot) {
      final messages =
          snapshot.docs.map((doc) => _messageFromDoc(doc, threadId)).toList()
            ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return messages;
    });
  }

  @override
  Future<String> ensureThread({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
  }) async {
    final threadId = _buildThreadId(currentUserId, otherUserId);
    final threadRef = _threads.doc(threadId);
    await threadRef.set({
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _userThreads(currentUserId).doc(threadId).set({
      'threadId': threadId,
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'otherUserId': otherUserId,
      'otherUserName': otherUserName ?? _displayName(otherUserId),
      'otherUserAvatar': otherUserAvatar ?? _avatar(otherUserId),
      'unreadCount': 0,
    }, SetOptions(merge: true));

    await _userThreads(otherUserId).doc(threadId).set({
      'threadId': threadId,
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'otherUserId': currentUserId,
      'otherUserName': _displayName(currentUserId),
      'otherUserAvatar': _avatar(currentUserId),
      'unreadCount': 0,
    }, SetOptions(merge: true));

    return threadId;
  }

  @override
  Future<void> sendMessage(Message message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;

    String threadId = message.threadId;
    if (threadId.isEmpty) {
      final receiverId = message.receiverId;
      if (receiverId == null || receiverId.isEmpty) {
        throw StateError('receiverId is required when sending first message.');
      }
      threadId = await ensureThread(
        currentUserId: message.senderId,
        otherUserId: receiverId,
      );
    }

    final threadRef = _threads.doc(threadId);
    final threadSnap = await threadRef.get();
    final data = threadSnap.data() ?? const {};
    final participants = (data['participantIds'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toSet()
        .toList();
    if (!participants.contains(message.senderId)) {
      participants.add(message.senderId);
    }
    if (message.receiverId != null &&
        message.receiverId!.isNotEmpty &&
        !participants.contains(message.receiverId)) {
      participants.add(message.receiverId!);
    }

    final messageRef = message.id.isEmpty
        ? _messages(threadId).doc()
        : _messages(threadId).doc(message.id);

    await messageRef.set({
      'threadId': threadId,
      'senderId': message.senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await threadRef.set({
      'participantIds': participants,
      'lastMessage': text,
      'lastSenderId': message.senderId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    for (final participantId in participants) {
      final otherUserId = participants.firstWhere(
        (id) => id != participantId,
        orElse: () => '',
      );
      final payload = <String, dynamic>{
        'threadId': threadId,
        'participantIds': participants,
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
        'otherUserId': otherUserId,
        'otherUserName': _displayName(otherUserId),
        'otherUserAvatar': _avatar(otherUserId),
      };
      if (participantId == message.senderId) {
        payload['unreadCount'] = 0;
      } else {
        payload['unreadCount'] = FieldValue.increment(1);
      }
      await _userThreads(
        participantId,
      ).doc(threadId).set(payload, SetOptions(merge: true));
    }

    for (final participantId in participants) {
      if (participantId == message.senderId) continue;
      try {
        await _notificationRepository.createNotification(
          AppNotification(
            id: '',
            userId: participantId,
            type: 'message',
            title: 'New Message',
            body: '${_displayName(message.senderId)}: $text',
            data: <String, dynamic>{
              'threadId': threadId,
              'senderId': message.senderId,
            },
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      } catch (_) {
        // Notification persistence must not block messaging flow.
      }
    }

    await _analytics.logSendMessage(threadId: threadId);
  }

  @override
  Future<void> markThreadAsRead({
    required String userId,
    required String threadId,
  }) async {
    await _userThreads(
      userId,
    ).doc(threadId).set({'unreadCount': 0}, SetOptions(merge: true));
  }

  ChatThread _threadFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();
    return ChatThread(
      id: doc.id,
      participantIds: (data['participantIds'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: updatedAt,
      otherUserId: data['otherUserId'] as String?,
      otherUserName: data['otherUserName'] as String?,
      otherUserAvatar: data['otherUserAvatar'] as String?,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Message _messageFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String fallbackThreadId,
  ) {
    final data = doc.data() ?? const {};
    final sentAtRaw = data['sentAt'];
    final sentAt = sentAtRaw is Timestamp ? sentAtRaw.toDate() : DateTime.now();
    return Message(
      id: doc.id,
      threadId: data['threadId'] as String? ?? fallbackThreadId,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: sentAt,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  String _buildThreadId(String firstUserId, String secondUserId) {
    final sorted = [firstUserId, secondUserId]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  String _displayName(String userId) {
    if (userId.isEmpty) return 'User';
    final short = userId.length > 6 ? userId.substring(0, 6) : userId;
    return 'User $short';
  }

  String _avatar(String userId) {
    if (userId.isEmpty) {
      return 'https://api.dicebear.com/7.x/avataaars/svg?seed=user';
    }
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$userId';
  }
}
