// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  id: json['id'] as String,
  userId: json['userId'] as String,
  subject: json['subject'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  status:
      $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
      TicketStatus.open,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  attachmentUrl: json['attachmentUrl'] as String?,
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'subject': instance.subject,
  'category': instance.category,
  'description': instance.description,
  'status': _$TicketStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'attachmentUrl': instance.attachmentUrl,
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};
