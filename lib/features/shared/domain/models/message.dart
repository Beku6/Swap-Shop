class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String? receiverId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    this.receiverId,
    required this.text,
    required this.sentAt,
    required this.isRead,
  });

  Message copyWith({
    String? id,
    String? threadId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
