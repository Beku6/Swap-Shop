import 'package:swap/features/notifications/domain/repositories/notification_repository.dart';
import 'package:swap/features/shared/domain/models/app_notification.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<AppNotification> _items;
  final Map<String, Set<String>> _deviceTokens = <String, Set<String>>{};

  FakeNotificationRepository({List<AppNotification> seed = const []})
    : _items = [...seed];

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    final items = _sortedByCreatedAtDesc(
      _items.where((item) => item.userId == userId).toList(),
    );
    return Stream.value(items);
  }

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    return _sortedByCreatedAtDesc(
      _items.where((item) => item.userId == userId).toList(),
    );
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    final id = notification.id.isEmpty
        ? 'n_${_items.length + 1}'
        : notification.id;
    _items.insert(
      0,
      notification.copyWith(id: id, createdAt: notification.createdAt),
    );
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    final index = _items.indexWhere(
      (item) => item.userId == userId && item.id == notificationId,
    );
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isRead: true);
  }

  @override
  Future<void> upsertDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    _deviceTokens.putIfAbsent(userId, () => <String>{}).add('$platform:$token');
  }

  bool hasDeviceToken(String userId, String platform, String token) {
    return _deviceTokens[userId]?.contains('$platform:$token') ?? false;
  }

  List<AppNotification> _sortedByCreatedAtDesc(List<AppNotification> items) {
    return [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
