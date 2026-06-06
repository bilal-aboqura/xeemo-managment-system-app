import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Product model representing a product that can be added to sales tickets
@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class Product with _$Product {
  const factory Product({
    /// Unique identifier for the product (UUID)
    required String productId,

    /// Product name (must be unique)
    required String name,

    /// Product price
    required double price,

    /// Product description/details
    @Default('') String details,

    /// When the product was created
    DateTime? createdAt,

    /// When the product was last updated
    DateTime? updatedAt,

    /// Sort order index
    @Default(0) int sortOrder,
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
