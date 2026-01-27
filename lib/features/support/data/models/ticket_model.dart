import 'package:json_annotation/json_annotation.dart';

part 'ticket_model.g.dart';

enum TicketStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
}

@JsonSerializable()
class Ticket {
  final String id;
  final String userId;
  final String subject;
  final String category; // e.g., 'Pesanan', 'Akun', 'Pembayaran'
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? attachmentUrl;

  const Ticket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.category,
    required this.description,
    this.status = TicketStatus.open,
    required this.createdAt,
    this.updatedAt,
    this.attachmentUrl,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
