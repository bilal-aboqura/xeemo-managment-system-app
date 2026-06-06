import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../providers/product_provider.dart';

/// Worker analytics data model
class WorkerAnalytics {
  final String workerId;
  final String workerName;
  final int ticketCount;
  final double totalSales;
  final List<ProductSalesData> topProducts;

  WorkerAnalytics({
    required this.workerId,
    required this.workerName,
    required this.ticketCount,
    required this.totalSales,
    required this.topProducts,
  });
}

/// Product sales data
class ProductSalesData {
  final String productId;
  final String productName;
  final int quantity;
  final double totalAmount;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalAmount,
  });
}

/// Provider for detailed worker analytics
final workerAnalyticsProvider = Provider.family<WorkerAnalytics?, String>((
  ref,
  workerId,
) {
  final ticketsState = ref.watch(ticketsProvider);
  final productsState = ref.watch(productsProvider);

  if (ticketsState.isLoading || productsState.isLoading) return null;

  // Filter tickets for this worker
  final workerTickets = ticketsState.tickets
      .where((t) => t.workerId == workerId)
      .toList();

  if (workerTickets.isEmpty) return null;

  // Calculate basic stats
  final workerName = workerTickets.first.workerName.isNotEmpty
      ? workerTickets.first.workerName
      : 'عامل غير معروف';
  final totalSales = workerTickets.fold<double>(
    0,
    (sum, t) => sum + t.saleAmount,
  );

  // Calculate product sales
  final Map<String, int> productQuantities = {};
  final Map<String, double> productAmounts = {};

  for (final ticket in workerTickets) {
    for (final productEntry in ticket.products) {
      productQuantities[productEntry.productId] =
          (productQuantities[productEntry.productId] ?? 0) +
          productEntry.quantity;

      // Find product price from products list
      final product = productsState.products.firstWhere(
        (p) => p.productId == productEntry.productId,
        orElse: () => productsState.products.isNotEmpty
            ? productsState.products.first
            : throw Exception('No products'),
      );

      final amount = product.price * productEntry.quantity;
      productAmounts[productEntry.productId] =
          (productAmounts[productEntry.productId] ?? 0) + amount;
    }
  }

  // Build top products list sorted by quantity
  final topProducts = productQuantities.entries.map((entry) {
    final product = productsState.products.firstWhere(
      (p) => p.productId == entry.key,
      orElse: () => productsState.products.isNotEmpty
          ? productsState.products.first
          : throw Exception('No products'),
    );

    return ProductSalesData(
      productId: entry.key,
      productName: product.name,
      quantity: entry.value,
      totalAmount: productAmounts[entry.key] ?? 0,
    );
  }).toList()..sort((a, b) => b.quantity.compareTo(a.quantity));

  return WorkerAnalytics(
    workerId: workerId,
    workerName: workerName,
    ticketCount: workerTickets.length,
    totalSales: totalSales,
    topProducts: topProducts.take(10).toList(), // Top 10 products
  );
});

/// Provider for all workers' analytics
final allWorkersAnalyticsProvider = Provider<List<WorkerAnalytics>>((ref) {
  final ticketsState = ref.watch(ticketsProvider);
  final productsState = ref.watch(productsProvider);

  if (ticketsState.isLoading || productsState.isLoading) return [];

  // Group tickets by worker
  final Map<String, List<SalesTicket>> ticketsByWorker = {};

  for (final ticket in ticketsState.tickets) {
    ticketsByWorker.putIfAbsent(ticket.workerId, () => []).add(ticket);
  }

  // Calculate analytics for each worker
  final analytics = ticketsByWorker.entries.map((entry) {
    final workerId = entry.key;
    final workerTickets = entry.value;

    final workerName = workerTickets.first.workerName.isNotEmpty
        ? workerTickets.first.workerName
        : 'عامل غير معروف';
    final totalSales = workerTickets.fold<double>(
      0,
      (sum, t) => sum + t.saleAmount,
    );

    // Calculate product sales
    final Map<String, int> productQuantities = {};
    final Map<String, double> productAmounts = {};

    for (final ticket in workerTickets) {
      for (final productEntry in ticket.products) {
        productQuantities[productEntry.productId] =
            (productQuantities[productEntry.productId] ?? 0) +
            productEntry.quantity;

        final product = productsState.products.firstWhere(
          (p) => p.productId == productEntry.productId,
          orElse: () => productsState.products.isNotEmpty
              ? productsState.products.first
              : throw Exception('No products'),
        );

        final amount = product.price * productEntry.quantity;
        productAmounts[productEntry.productId] =
            (productAmounts[productEntry.productId] ?? 0) + amount;
      }
    }

    final topProducts = productQuantities.entries.map((e) {
      final product = productsState.products.firstWhere(
        (p) => p.productId == e.key,
        orElse: () => productsState.products.isNotEmpty
            ? productsState.products.first
            : throw Exception('No products'),
      );

      return ProductSalesData(
        productId: e.key,
        productName: product.name,
        quantity: e.value,
        totalAmount: productAmounts[e.key] ?? 0,
      );
    }).toList()..sort((a, b) => b.quantity.compareTo(a.quantity));

    return WorkerAnalytics(
      workerId: workerId,
      workerName: workerName,
      ticketCount: workerTickets.length,
      totalSales: totalSales,
      topProducts: topProducts.take(10).toList(),
    );
  }).toList();

  // Sort by total sales descending
  analytics.sort((a, b) => b.totalSales.compareTo(a.totalSales));

  return analytics;
});
