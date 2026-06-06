import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String _getCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('1 لتر') ||
        n.contains('١ لتر') ||
        n.contains('١لتر') ||
        n.contains('1لتر')) {
      return 'عبوات 1 لتر';
    }
    if (n.contains('4ك') ||
        n.contains('٤ك') ||
        n.contains('4 ك') ||
        n.contains('٤ ك')) {
      return 'جراكن 4 كيلو';
    }
    if (n.contains('20ك') ||
        n.contains('٢٠ك') ||
        n.contains('20 ك') ||
        n.contains('٢٠ ك')) {
      return 'جراكن 20 كيلو';
    }
    return 'منتجات أخرى';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'عبوات 1 لتر':
        return Colors.blue;
      case 'جراكن 4 كيلو':
        return Colors.orange;
      case 'جراكن 20 كيلو':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;

    if (productsState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات متاحة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    // Group products
    final groupedProducts = <String, List<Product>>{};
    for (var product in products) {
      final category = _getCategory(product.name);
      if (!groupedProducts.containsKey(category)) {
        groupedProducts[category] = [];
      }
      groupedProducts[category]!.add(product);
    }

    // Sort keys to ensure consistent order (1L, 4kg, 20kg, Other)
    final sortedKeys = groupedProducts.keys.toList()
      ..sort((a, b) {
        if (a == b) return 0;
        if (a == 'عبوات 1 لتر') return -1;
        if (b == 'عبوات 1 لتر') return 1;
        if (a == 'جراكن 4 كيلو') return -1;
        if (b == 'جراكن 4 كيلو') return 1;
        if (a == 'جراكن 20 كيلو') return -1;
        if (b == 'جراكن 20 كيلو') return 1;
        return a.compareTo(b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر المنتجات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...sortedKeys.map((category) {
          final categoryProducts = groupedProducts[category]!;
          final color = _getCategoryColor(category);
          final selectedCount = categoryProducts
              .where((p) => (_quantities[p.productId] ?? 0) > 0)
              .length;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded:
                    selectedCount > 0, // Auto expand if has selection
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.category_outlined, color: color),
                ),
                title: Text(
                  category,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectedCount',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.expand_more, color: color),
                  ],
                ),
                children: categoryProducts
                    .map(
                      (product) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _ProductTile(
                          product: product,
                          quantity: _quantities[product.productId] ?? 0,
                          onQuantityChanged: (q) => _updateQuantity(product, q),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }),
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
    final isSelected = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryRed.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatEGP(product.price),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.details.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        product.details,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 20,
                      color: quantity > 0
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: quantity > 0
                        ? () => onQuantityChanged(quantity - 1)
                        : null,
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF4B5563),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),
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
