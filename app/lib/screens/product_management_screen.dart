import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../core/theme.dart';

/// Screen for managing products (CRUD)
class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh products on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  void _showAddEditProductDialog([Product? product]) {
    showDialog(
      context: context,
      builder: (context) => _AddEditProductDialog(
        product: product,
        onSave: (newProduct) {
          if (product == null) {
            ref.read(productsProvider.notifier).addProduct(newProduct);
          } else {
            ref.read(productsProvider.notifier).updateProduct(newProduct);
          }
        },
      ),
    );
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج؟'),
        content: const Text(
          'هل أنت متأكد من حذف هذا المنتج؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(productId);
              Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditProductDialog(),
        child: const Icon(Icons.add),
        tooltip: 'إضافة منتج',
      ),
      body: productsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productsState.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات بعد',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة منتج'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: productsState.products.length,
              itemBuilder: (context, index) {
                final product = productsState.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        product.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.formatEGP(product.price),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.details.isNotEmpty)
                          Text(
                            product.details,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditProductDialog(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.productId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AddEditProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const _AddEditProductDialog({this.product, required this.onSave});

  @override
  State<_AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<_AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _detailsController = TextEditingController(text: widget.product?.details);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      productId: widget.product?.productId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      details: _detailsController.text.trim(),
    );

    widget.onSave(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل منتج'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اسم المنتج مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر *',
                  suffixText: 'ج.م',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'السعر مطلوب';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال سعر صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'التفاصيل'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.product == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}
