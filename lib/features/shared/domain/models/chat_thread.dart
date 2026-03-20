class ChatThread {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime updatedAt;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final int unreadCount;

  const ChatThread({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.updatedAt,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.unreadCount = 0,
  });

  ChatThread copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? updatedAt,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    int? unreadCount,
  }) {
    return ChatThread(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
