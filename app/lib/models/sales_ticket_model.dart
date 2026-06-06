import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_ticket_model.freezed.dart';
part 'sales_ticket_model.g.dart';

/// Status of a sales ticket
enum TicketStatus {
  /// Ticket is saved locally, not yet synced
  @JsonValue('draft')
  draft,

  /// Ticket is queued for submission
  @JsonValue('queued')
  queued,

  /// Ticket has been submitted to the database
  @JsonValue('submitted')
  submitted,

  /// Submission failed and needs retry
  @JsonValue('failed')
  failed,
}

/// Sales ticket model representing a sales transaction
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class SalesTicket with _$SalesTicket {
  const factory SalesTicket({
    /// Unique identifier for the ticket (UUID)
    required String ticketId,

    /// Client's name
    required String clientName,

    /// Client's phone number
    required String clientPhone,

    /// Name of the laundry business
    @Default('') String laundryName,

    /// Notes from the worker
    @Default('') String workerNotes,

    /// Notes from the client
    @Default('') String clientNotes,

    /// Total sale amount
    required double saleAmount,

    /// ID of the worker who created the ticket
    required String workerId,

    /// Name of the worker who created the ticket
    @Default('') String workerName,

    /// List of product IDs with quantities
    required List<TicketProductEntry> products,

    /// Location latitude
    required double latitude,

    /// Location longitude
    required double longitude,

    /// When the ticket was created
    required DateTime createdAt,

    /// Current status of the ticket
    @Default(TicketStatus.draft) TicketStatus status,
  }) = _SalesTicket;

  factory SalesTicket.fromJson(Map<String, dynamic> json) =>
      _$SalesTicketFromJson(json);
}

/// Entry for a product in a ticket (product ID and quantity)
@freezed
class TicketProductEntry with _$TicketProductEntry {
  const factory TicketProductEntry({
    /// Product ID
    required String productId,

    /// Quantity of the product
    required int quantity,
  }) = _TicketProductEntry;

  factory TicketProductEntry.fromJson(Map<String, dynamic> json) =>
      _$TicketProductEntryFromJson(json);
}

/// Extension methods for SalesTicket
extension SalesTicketExtension on SalesTicket {
  /// Check if the ticket is synced to the server
  bool get isSynced => status == TicketStatus.submitted;

  /// Check if the ticket needs to be synced
  bool get needsSync =>
      status == TicketStatus.draft ||
      status == TicketStatus.queued ||
      status == TicketStatus.failed;

  /// Check if the ticket has valid location
  bool get hasValidLocation => latitude != 0.0 && longitude != 0.0;
}
