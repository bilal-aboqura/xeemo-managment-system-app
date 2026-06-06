// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  /// Unique identifier for the product (UUID)
  String get productId => throw _privateConstructorUsedError;

  /// Product name (must be unique)
  String get name => throw _privateConstructorUsedError;

  /// Product price
  double get price => throw _privateConstructorUsedError;

  /// Product description/details
  String get details => throw _privateConstructorUsedError;

  /// When the product was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the product was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Sort order index
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String productId,
    String name,
    double price,
    String details,
    DateTime? createdAt,
    DateTime? updatedAt,
    int sortOrder,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? details = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String name,
    double price,
    String details,
    DateTime? createdAt,
    DateTime? updatedAt,
    int sortOrder,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? details = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _$ProductImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        details: null == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.productId,
    required this.name,
    required this.price,
    this.details = '',
    this.createdAt,
    this.updatedAt,
    this.sortOrder = 0,
  });

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  /// Unique identifier for the product (UUID)
  @override
  final String productId;

  /// Product name (must be unique)
  @override
  final String name;

  /// Product price
  @override
  final double price;

  /// Product description/details
  @override
  @JsonKey()
  final String details;

  /// When the product was created
  @override
  final DateTime? createdAt;

  /// When the product was last updated
  @override
  final DateTime? updatedAt;

  /// Sort order index
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'Product(productId: $productId, name: $name, price: $price, details: $details, createdAt: $createdAt, updatedAt: $updatedAt, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    name,
    price,
    details,
    createdAt,
    updatedAt,
    sortOrder,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final String productId,
    required final String name,
    required final double price,
    final String details,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final int sortOrder,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  /// Unique identifier for the product (UUID)
  @override
  String get productId;

  /// Product name (must be unique)
  @override
  String get name;

  /// Product price
  @override
  double get price;

  /// Product description/details
  @override
  String get details;

  /// When the product was created
  @override
  DateTime? get createdAt;

  /// When the product was last updated
  @override
  DateTime? get updatedAt;

  /// Sort order index
  @override
  int get sortOrder;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TicketProduct _$TicketProductFromJson(Map<String, dynamic> json) {
  return _TicketProduct.fromJson(json);
}

/// @nodoc
mixin _$TicketProduct {
  /// The product
  Product get product => throw _privateConstructorUsedError;

  /// Quantity selected
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this TicketProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketProductCopyWith<TicketProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketProductCopyWith<$Res> {
  factory $TicketProductCopyWith(
    TicketProduct value,
    $Res Function(TicketProduct) then,
  ) = _$TicketProductCopyWithImpl<$Res, TicketProduct>;
  @useResult
  $Res call({Product product, int quantity});

  $ProductCopyWith<$Res> get product;
}

/// @nodoc
class _$TicketProductCopyWithImpl<$Res, $Val extends TicketProduct>
    implements $TicketProductCopyWith<$Res> {
  _$TicketProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? product = null, Object? quantity = null}) {
    return _then(
      _value.copyWith(
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as Product,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductCopyWith<$Res> get product {
    return $ProductCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TicketProductImplCopyWith<$Res>
    implements $TicketProductCopyWith<$Res> {
  factory _$$TicketProductImplCopyWith(
    _$TicketProductImpl value,
    $Res Function(_$TicketProductImpl) then,
  ) = __$$TicketProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Product product, int quantity});

  @override
  $ProductCopyWith<$Res> get product;
}

/// @nodoc
class __$$TicketProductImplCopyWithImpl<$Res>
    extends _$TicketProductCopyWithImpl<$Res, _$TicketProductImpl>
    implements _$$TicketProductImplCopyWith<$Res> {
  __$$TicketProductImplCopyWithImpl(
    _$TicketProductImpl _value,
    $Res Function(_$TicketProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? product = null, Object? quantity = null}) {
    return _then(
      _$TicketProductImpl(
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as Product,
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
class _$TicketProductImpl implements _TicketProduct {
  const _$TicketProductImpl({required this.product, required this.quantity});

  factory _$TicketProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketProductImplFromJson(json);

  /// The product
  @override
  final Product product;

  /// Quantity selected
  @override
  final int quantity;

  @override
  String toString() {
    return 'TicketProduct(product: $product, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketProductImpl &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, product, quantity);

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketProductImplCopyWith<_$TicketProductImpl> get copyWith =>
      __$$TicketProductImplCopyWithImpl<_$TicketProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketProductImplToJson(this);
  }
}

abstract class _TicketProduct implements TicketProduct {
  const factory _TicketProduct({
    required final Product product,
    required final int quantity,
  }) = _$TicketProductImpl;

  factory _TicketProduct.fromJson(Map<String, dynamic> json) =
      _$TicketProductImpl.fromJson;

  /// The product
  @override
  Product get product;

  /// Quantity selected
  @override
  int get quantity;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketProductImplCopyWith<_$TicketProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
