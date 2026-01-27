// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRead: json['isRead'] as bool? ?? false,
  type: json['type'] as String? ?? 'text',
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRead': instance.isRead,
      'type': instance.type,
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  shopName: json['shopName'] as String,
  shopLogo: json['shopLogo'] as String,
  lastMessage: json['lastMessage'] == null
      ? null
      : ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'shopLogo': instance.shopLogo,
  'lastMessage': instance.lastMessage,
  'unreadCount': instance.unreadCount,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
