import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import '../config/app_config.dart';

/// State for product list
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing products state
class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier() : super(const ProductsState()) {
    loadProducts();
  }

  /// Load all products from database
  Future<void> loadProducts() async {
    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured, using mock products');
      state = ProductsState(
        products: _getMockProducts(),
        isLoading: false,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client
          .from('products')
          .select()
          .order('name');

      final products = (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      state = ProductsState(products: products, isLoading: false);
      SupabaseService.logInfo('Loaded ${products.length} products');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to load products', e, stackTrace);
      state = ProductsState(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Add a new product (Manager only)
  Future<void> addProduct(Product product) async {
    if (!AppConfig.isSupabaseConfigured) {
      state = state.copyWith(
        products: [...state.products, product],
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      await SupabaseService.client.from('products').insert({
        'product_id': product.productId,
        'name': product.name,
        'price': product.price,
        'details': product.details,
      });

      await loadProducts();
      SupabaseService.logInfo('Product added: ${product.name}');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to add product', e, stackTrace);
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  /// Update an existing product (Manager only)
  Future<void> updateProduct(Product product) async {
    if (!AppConfig.isSupabaseConfigured) {
      final index = state.products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        final updated = [...state.products];
        updated[index] = product;
        state = state.copyWith(products: updated);
      }
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      await SupabaseService.client
          .from('products')
          .update({
            'name': product.name,
            'price': product.price,
            'details': product.details,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('product_id', product.productId);

      await loadProducts();
      SupabaseService.logInfo('Product updated: ${product.name}');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to update product', e, stackTrace);
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  /// Delete a product (Manager only)
  Future<void> deleteProduct(String productId) async {
    if (!AppConfig.isSupabaseConfigured) {
      final updated = state.products.where((p) => p.productId != productId).toList();
      state = state.copyWith(products: updated);
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      await SupabaseService.client
          .from('products')
          .delete()
          .eq('product_id', productId);

      await loadProducts();
      SupabaseService.logInfo('Product deleted: $productId');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to delete product', e, stackTrace);
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  /// Get mock products for development without Supabase
  List<Product> _getMockProducts() {
    return [
      Product(
        productId: '1',
        name: 'Product A',
        price: 29.99,
        details: 'Sample product A description',
      ),
      Product(
        productId: '2',
        name: 'Product B',
        price: 49.99,
        details: 'Sample product B description',
      ),
      Product(
        productId: '3',
        name: 'Product C',
        price: 99.99,
        details: 'Sample product C description',
      ),
    ];
  }
}

/// Provider for products state
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier();
});

/// Provider for product list
final productListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsProvider).products;
});

/// Provider for single product by ID
final productByIdProvider = Provider.family<Product?, String>((ref, productId) {
  final products = ref.watch(productListProvider);
  try {
    return products.firstWhere((p) => p.productId == productId);
  } catch (_) {
    return null;
  }
});
