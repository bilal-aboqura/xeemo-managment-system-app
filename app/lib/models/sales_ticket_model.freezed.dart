// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_ticket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SalesTicket _$SalesTicketFromJson(Map<String, dynamic> json) {
  return _SalesTicket.fromJson(json);
}

/// @nodoc
mixin _$SalesTicket {
  /// Unique identifier for the ticket (UUID)
  String get ticketId => throw _privateConstructorUsedError;

  /// Client's name
  String get clientName => throw _privateConstructorUsedError;

  /// Client's phone number
  String get clientPhone => throw _privateConstructorUsedError;

  /// Name of the laundry business
  String get laundryName => throw _privateConstructorUsedError;

  /// Notes from the worker
  String get workerNotes => throw _privateConstructorUsedError;

  /// Notes from the client
  String get clientNotes => throw _privateConstructorUsedError;

  /// Total sale amount
  double get saleAmount => throw _privateConstructorUsedError;

  /// ID of the worker who created the ticket
  String get workerId => throw _privateConstructorUsedError;

  /// Name of the worker who created the ticket
  String get workerName => throw _privateConstructorUsedError;

  /// List of product IDs with quantities
  List<TicketProductEntry> get products => throw _privateConstructorUsedError;

  /// Location latitude
  double get latitude => throw _privateConstructorUsedError;

  /// Location longitude
  double get longitude => throw _privateConstructorUsedError;

  /// When the ticket was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Current status of the ticket
  TicketStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SalesTicket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesTicketCopyWith<SalesTicket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesTicketCopyWith<$Res> {
  factory $SalesTicketCopyWith(
    SalesTicket value,
    $Res Function(SalesTicket) then,
  ) = _$SalesTicketCopyWithImpl<$Res, SalesTicket>;
  @useResult
  $Res call({
    String ticketId,
    String clientName,
    String clientPhone,
    String laundryName,
    String workerNotes,
    String clientNotes,
    double saleAmount,
    String workerId,
    String workerName,
    List<TicketProductEntry> products,
    double latitude,
    double longitude,
    DateTime createdAt,
    TicketStatus status,
  });
}

/// @nodoc
class _$SalesTicketCopyWithImpl<$Res, $Val extends SalesTicket>
    implements $SalesTicketCopyWith<$Res> {
  _$SalesTicketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticketId = null,
    Object? clientName = null,
    Object? clientPhone = null,
    Object? laundryName = null,
    Object? workerNotes = null,
    Object? clientNotes = null,
    Object? saleAmount = null,
    Object? workerId = null,
    Object? workerName = null,
    Object? products = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            ticketId: null == ticketId
                ? _value.ticketId
                : ticketId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientName: null == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String,
            clientPhone: null == clientPhone
                ? _value.clientPhone
                : clientPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            laundryName: null == laundryName
                ? _value.laundryName
                : laundryName // ignore: cast_nullable_to_non_nullable
                      as String,
            workerNotes: null == workerNotes
                ? _value.workerNotes
                : workerNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            clientNotes: null == clientNotes
                ? _value.clientNotes
                : clientNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            saleAmount: null == saleAmount
                ? _value.saleAmount
                : saleAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            workerId: null == workerId
                ? _value.workerId
                : workerId // ignore: cast_nullable_to_non_nullable
                      as String,
            workerName: null == workerName
                ? _value.workerName
                : workerName // ignore: cast_nullable_to_non_nullable
                      as String,
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as List<TicketProductEntry>,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TicketStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesTicketImplCopyWith<$Res>
    implements $SalesTicketCopyWith<$Res> {
  factory _$$SalesTicketImplCopyWith(
    _$SalesTicketImpl value,
    $Res Function(_$SalesTicketImpl) then,
  ) = __$$SalesTicketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ticketId,
    String clientName,
    String clientPhone,
    String laundryName,
    String workerNotes,
    String clientNotes,
    double saleAmount,
    String workerId,
    String workerName,
    List<TicketProductEntry> products,
    double latitude,
    double longitude,
    DateTime createdAt,
    TicketStatus status,
  });
}

/// @nodoc
class __$$SalesTicketImplCopyWithImpl<$Res>
    extends _$SalesTicketCopyWithImpl<$Res, _$SalesTicketImpl>
    implements _$$SalesTicketImplCopyWith<$Res> {
  __$$SalesTicketImplCopyWithImpl(
    _$SalesTicketImpl _value,
    $Res Function(_$SalesTicketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticketId = null,
    Object? clientName = null,
    Object? clientPhone = null,
    Object? laundryName = null,
    Object? workerNotes = null,
    Object? clientNotes = null,
    Object? saleAmount = null,
    Object? workerId = null,
    Object? workerName = null,
    Object? products = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? status = null,
  }) {
    return _then(
      _$SalesTicketImpl(
        ticketId: null == ticketId
            ? _value.ticketId
            : ticketId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientName: null == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String,
        clientPhone: null == clientPhone
            ? _value.clientPhone
            : clientPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        laundryName: null == laundryName
            ? _value.laundryName
            : laundryName // ignore: cast_nullable_to_non_nullable
                  as String,
        workerNotes: null == workerNotes
            ? _value.workerNotes
            : workerNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        clientNotes: null == clientNotes
            ? _value.clientNotes
            : clientNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        saleAmount: null == saleAmount
            ? _value.saleAmount
            : saleAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        workerId: null == workerId
            ? _value.workerId
            : workerId // ignore: cast_nullable_to_non_nullable
                  as String,
        workerName: null == workerName
            ? _value.workerName
            : workerName // ignore: cast_nullable_to_non_nullable
                  as String,
        products: null == products
            ? _value._products
            : products // ignore: cast_nullable_to_non_nullable
                  as List<TicketProductEntry>,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TicketStatus,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$SalesTicketImpl implements _SalesTicket {
  const _$SalesTicketImpl({
    required this.ticketId,
    required this.clientName,
    required this.clientPhone,
    this.laundryName = '',
    this.workerNotes = '',
    this.clientNotes = '',
    required this.saleAmount,
    required this.workerId,
    this.workerName = '',
    required final List<TicketProductEntry> products,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.status = TicketStatus.draft,
  }) : _products = products;

  factory _$SalesTicketImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesTicketImplFromJson(json);

  /// Unique identifier for the ticket (UUID)
  @override
  final String ticketId;

  /// Client's name
  @override
  final String clientName;

  /// Client's phone number
  @override
  final String clientPhone;

  /// Name of the laundry business
  @override
  @JsonKey()
  final String laundryName;

  /// Notes from the worker
  @override
  @JsonKey()
  final String workerNotes;

  /// Notes from the client
  @override
  @JsonKey()
  final String clientNotes;

  /// Total sale amount
  @override
  final double saleAmount;

  /// ID of the worker who created the ticket
  @override
  final String workerId;

  /// Name of the worker who created the ticket
  @override
  @JsonKey()
  final String workerName;

  /// List of product IDs with quantities
  final List<TicketProductEntry> _products;

  /// List of product IDs with quantities
  @override
  List<TicketProductEntry> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  /// Location latitude
  @override
  final double latitude;

  /// Location longitude
  @override
  final double longitude;

  /// When the ticket was created
  @override
  final DateTime createdAt;

  /// Current status of the ticket
  @override
  @JsonKey()
  final TicketStatus status;

  @override
  String toString() {
    return 'SalesTicket(ticketId: $ticketId, clientName: $clientName, clientPhone: $clientPhone, laundryName: $laundryName, workerNotes: $workerNotes, clientNotes: $clientNotes, saleAmount: $saleAmount, workerId: $workerId, workerName: $workerName, products: $products, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesTicketImpl &&
            (identical(other.ticketId, ticketId) ||
                other.ticketId == ticketId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.clientPhone, clientPhone) ||
                other.clientPhone == clientPhone) &&
            (identical(other.laundryName, laundryName) ||
                other.laundryName == laundryName) &&
            (identical(other.workerNotes, workerNotes) ||
                other.workerNotes == workerNotes) &&
            (identical(other.clientNotes, clientNotes) ||
                other.clientNotes == clientNotes) &&
            (identical(other.saleAmount, saleAmount) ||
                other.saleAmount == saleAmount) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.workerName, workerName) ||
                other.workerName == workerName) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ticketId,
    clientName,
    clientPhone,
    laundryName,
    workerNotes,
    clientNotes,
    saleAmount,
    workerId,
    workerName,
    const DeepCollectionEquality().hash(_products),
    latitude,
    longitude,
    createdAt,
    status,
  );

  /// Create a copy of SalesTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesTicketImplCopyWith<_$SalesTicketImpl> get copyWith =>
      __$$SalesTicketImplCopyWithImpl<_$SalesTicketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesTicketImplToJson(this);
  }
}

abstract class _SalesTicket implements SalesTicket {
  const factory _SalesTicket({
    required final String ticketId,
    required final String clientName,
    required final String clientPhone,
    final String laundryName,
    final String workerNotes,
    final String clientNotes,
    required final double saleAmount,
    required final String workerId,
    final String workerName,
    required final List<TicketProductEntry> products,
    required final double latitude,
    required final double longitude,
    required final DateTime createdAt,
    final TicketStatus status,
  }) = _$SalesTicketImpl;

  factory _SalesTicket.fromJson(Map<String, dynamic> json) =
      _$SalesTicketImpl.fromJson;

  /// Unique identifier for the ticket (UUID)
  @override
  String get ticketId;

  /// Client's name
  @override
  String get clientName;

  /// Client's phone number
  @override
  String get clientPhone;

  /// Name of the laundry business
  @override
  String get laundryName;

  /// Notes from the worker
  @override
  String get workerNotes;

  /// Notes from the client
  @override
  String get clientNotes;

  /// Total sale amount
  @override
  double get saleAmount;

  /// ID of the worker who created the ticket
  @override
  String get workerId;

  /// Name of the worker who created the ticket
  @override
  String get workerName;

  /// List of product IDs with quantities
  @override
  List<TicketProductEntry> get products;

  /// Location latitude
  @override
  double get latitude;

  /// Location longitude
  @override
  double get longitude;

  /// When the ticket was created
  @override
  DateTime get createdAt;

  /// Current status of the ticket
  @override
  TicketStatus get status;

  /// Create a copy of SalesTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesTicketImplCopyWith<_$SalesTicketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TicketProductEntry _$TicketProductEntryFromJson(Map<String, dynamic> json) {
  return _TicketProductEntry.fromJson(json);
}

/// @nodoc
mixin _$TicketProductEntry {
  /// Product ID
  String get productId => throw _privateConstructorUsedError;

  /// Quantity of the product
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this TicketProductEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TicketProductEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketProductEntryCopyWith<TicketProductEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketProductEntryCopyWith<$Res> {
  factory $TicketProductEntryCopyWith(
    TicketProductEntry value,
    $Res Function(TicketProductEntry) then,
  ) = _$TicketProductEntryCopyWithImpl<$Res, TicketProductEntry>;
  @useResult
  $Res call({String productId, int quantity});
}

/// @nodoc
class _$TicketProductEntryCopyWithImpl<$Res, $Val extends TicketProductEntry>
    implements $TicketProductEntryCopyWith<$Res> {
  _$TicketProductEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TicketProductEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? quantity = null}) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TicketProductEntryImplCopyWith<$Res>
    implements $TicketProductEntryCopyWith<$Res> {
  factory _$$TicketProductEntryImplCopyWith(
    _$TicketProductEntryImpl value,
    $Res Function(_$TicketProductEntryImpl) then,
  ) = __$$TicketProductEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productId, int quantity});
}

/// @nodoc
class __$$TicketProductEntryImplCopyWithImpl<$Res>
    extends _$TicketProductEntryCopyWithImpl<$Res, _$TicketProductEntryImpl>
    implements _$$TicketProductEntryImplCopyWith<$Res> {
  __$$TicketProductEntryImplCopyWithImpl(
    _$TicketProductEntryImpl _value,
    $Res Function(_$TicketProductEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TicketProductEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? quantity = null}) {
    return _then(
      _$TicketProductEntryImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketProductEntryImpl implements _TicketProductEntry {
  const _$TicketProductEntryImpl({
    required this.productId,
    required this.quantity,
  });

  factory _$TicketProductEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketProductEntryImplFromJson(json);

  /// Product ID
  @override
  final String productId;

  /// Quantity of the product
  @override
  final int quantity;

  @override
  String toString() {
    return 'TicketProductEntry(productId: $productId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketProductEntryImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, quantity);

  /// Create a copy of TicketProductEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketProductEntryImplCopyWith<_$TicketProductEntryImpl> get copyWith =>
      __$$TicketProductEntryImplCopyWithImpl<_$TicketProductEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketProductEntryImplToJson(this);
  }
}

abstract class _TicketProductEntry implements TicketProductEntry {
  const factory _TicketProductEntry({
    required final String productId,
    required final int quantity,
  }) = _$TicketProductEntryImpl;

  factory _TicketProductEntry.fromJson(Map<String, dynamic> json) =
      _$TicketProductEntryImpl.fromJson;

  /// Product ID
  @override
  String get productId;

  /// Quantity of the product
  @override
  int get quantity;

  /// Create a copy of TicketProductEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketProductEntryImplCopyWith<_$TicketProductEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
