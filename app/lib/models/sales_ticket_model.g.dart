// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalesTicketImpl _$$SalesTicketImplFromJson(Map<String, dynamic> json) =>
    _$SalesTicketImpl(
      ticketId: json['ticket_id'] as String,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String,
      laundryName: json['laundry_name'] as String? ?? '',
      workerNotes: json['worker_notes'] as String? ?? '',
      clientNotes: json['client_notes'] as String? ?? '',
      saleAmount: (json['sale_amount'] as num).toDouble(),
      workerId: json['worker_id'] as String,
      workerName: json['worker_name'] as String? ?? '',
      products: (json['products'] as List<dynamic>)
          .map((e) => TicketProductEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      status:
          $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
          TicketStatus.draft,
    );

Map<String, dynamic> _$$SalesTicketImplToJson(_$SalesTicketImpl instance) =>
    <String, dynamic>{
      'ticket_id': instance.ticketId,
      'client_name': instance.clientName,
      'client_phone': instance.clientPhone,
      'laundry_name': instance.laundryName,
      'worker_notes': instance.workerNotes,
      'client_notes': instance.clientNotes,
      'sale_amount': instance.saleAmount,
      'worker_id': instance.workerId,
      'worker_name': instance.workerName,
      'products': instance.products,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt.toIso8601String(),
      'status': _$TicketStatusEnumMap[instance.status]!,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.draft: 'draft',
  TicketStatus.queued: 'queued',
  TicketStatus.submitted: 'submitted',
  TicketStatus.failed: 'failed',
};

_$TicketProductEntryImpl _$$TicketProductEntryImplFromJson(
  Map<String, dynamic> json,
) => _$TicketProductEntryImpl(
  productId: json['productId'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$$TicketProductEntryImplToJson(
  _$TicketProductEntryImpl instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'quantity': instance.quantity,
};
