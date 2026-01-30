import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../core/theme.dart';

/// Widget for selecting products with quantities
class ProductSelector extends ConsumerStatefulWidget {
  /// Callback when selection changes
  final void Function(List<SelectedProduct> products) onChanged;

  /// Initial selection
  final List<SelectedProduct>? initialSelection;

  const ProductSelector({
    super.key,
    required this.onChanged,
    this.initialSelection,
  });

  @override
  ConsumerState<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends ConsumerState<ProductSelector> {
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      for (final item in widget.initialSelection!) {
        _quantities[item.product.productId] = item.quantity;
      }
    }
  }

  void _updateQuantity(Product product, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(product.productId);
      } else {
        _quantities[product.productId] = quantity;
      }
    });
    _notifyChange();
  }

  void _notifyChange() {
    final products = ref.read(productListProvider);
    final selected = <SelectedProduct>[];

    for (final entry in _quantities.entries) {
      final product = products.firstWhere(
        (p) => p.productId == entry.key,
        orElse: () =>
            Product(productId: entry.key, name: 'غير معروف', price: 0),
      );
      selected.add(SelectedProduct(product: product, quantity: entry.value));
    }

    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;
    final colorScheme = Theme.of(context).colorScheme;

    if (productsState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'لا توجد منتجات متاحة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر المنتجات',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...products.map(
          (product) => _ProductTile(
            product: product,
            quantity: _quantities[product.productId] ?? 0,
            onQuantityChanged: (q) => _updateQuantity(product, q),
          ),
        ),
        if (_quantities.isNotEmpty) ...[
          const Divider(),
          _TotalSummary(products: products, quantities: _quantities),
        ],
      ],
    );
  }
}

/// Single product tile with quantity controls
class _ProductTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final void Function(int) onQuantityChanged;

  const _ProductTile({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = quantity > 0;

    return Card(
      color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatEGP(product.price),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (product.details.isNotEmpty)
                    Text(
                      product.details,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: quantity > 0
                      ? () => onQuantityChanged(quantity - 1)
                      : null,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onQuantityChanged(quantity + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary of selected products total
class _TotalSummary extends StatelessWidget {
  final List<Product> products;
  final Map<String, int> quantities;

  const _TotalSummary({required this.products, required this.quantities});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    double total = 0;
    int itemCount = 0;

    for (final entry in quantities.entries) {
      final product = products.firstWhere(
        (p) => p.productId == entry.key,
        orElse: () => Product(productId: '', name: '', price: 0),
      );
      total += product.price * entry.value;
      itemCount += entry.value;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$itemCount ${itemCount != 1 ? 'عناصر' : 'عنصر'} محدد',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'الإجمالي: ${CurrencyFormatter.formatEGP(total)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a selected product with quantity
class SelectedProduct {
  final Product product;
  final int quantity;

  SelectedProduct({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}
