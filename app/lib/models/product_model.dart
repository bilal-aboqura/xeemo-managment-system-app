import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Product model representing a product that can be added to sales tickets
@freezed
class Product with _$Product {
  const factory Product({
    /// Unique identifier for the product (UUID)
    @JsonKey(name: 'product_id') required String productId,

    /// Product name (must be unique)
    required String name,

    /// Product price
    required double price,

    /// Product description/details
    @Default('') String details,

    /// When the product was created
    @JsonKey(name: 'created_at') DateTime? createdAt,

    /// When the product was last updated
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// Quantity-based product selection for tickets
@freezed
class TicketProduct with _$TicketProduct {
  const factory TicketProduct({
    /// The product
    required Product product,

    /// Quantity selected
    required int quantity,
  }) = _TicketProduct;

  factory TicketProduct.fromJson(Map<String, dynamic> json) =>
      _$TicketProductFromJson(json);
}

/// Extension methods for TicketProduct
extension TicketProductExtension on TicketProduct {
  /// Calculate the total price for this product line
  double get totalPrice => product.price * quantity;
}
