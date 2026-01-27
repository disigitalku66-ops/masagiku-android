import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // 'text', 'image', 'product'

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class ChatRoom {
  final String id;
  final String shopId;
  final String shopName;
  final String shopLogo;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopLogo,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
}
