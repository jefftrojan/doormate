import 'package:intl/intl.dart';

enum MessageSender {
  user,
  assistant,
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Handle different timestamp formats
    DateTime parseTimestamp() {
      final timestamp = json['timestamp'] ?? json['created_at'];
      if (timestamp == null) {
        return DateTime.now();
      }
      
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.now();
      }
    }

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? json['chatId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: parseTimestamp(),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  // Check if the message is from the current user
  // This is now handled by the MessagingProvider
  bool get isFromCurrentUser => senderId == 'current-user-id';
} 