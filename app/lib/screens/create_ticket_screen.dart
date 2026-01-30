import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sales_ticket_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../services/geolocation_service.dart';
import '../services/ticket_queue_service.dart';
import '../widgets/sales_ticket_form.dart';
import '../widgets/product_selector.dart';
import '../core/theme.dart';

/// Screen for workers to create sales tickets
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _geolocationService = GeolocationService();
  final _ticketQueueService = TicketQueueService();

  int _currentStep = 0;
  bool _isSubmitting = false;
  Position? _currentLocation;
  String? _locationError;
  bool _isCapturingLocation = false;

  SalesTicketFormData? _formData;
  List<SelectedProduct> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isCapturingLocation = true;
      _locationError = null;
    });

    try {
      final position = await _geolocationService.getCurrentLocation();
      setState(() {
        _currentLocation = position;
        _isCapturingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isCapturingLocation = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formData == null) return;
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الموقع مطلوب. يرجى تحديد الموقع أولاً.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate sale amount from selected products
      final calculatedSaleAmount = _selectedProducts.fold<double>(
        0,
        (sum, p) => sum + p.totalPrice,
      );

      final ticket = SalesTicket(
        ticketId: const Uuid().v4(),
        clientName: _formData!.clientName,
        clientPhone: _formData!.clientPhone,
        workerNotes: _formData!.workerNotes,
        clientNotes: _formData!.clientNotes,
        saleAmount: calculatedSaleAmount,
        workerId: user.userId,
        products: _selectedProducts
            .map(
              (p) => TicketProductEntry(
                productId: p.product.productId,
                quantity: p.quantity,
              ),
            )
            .toList(),
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        createdAt: DateTime.now(),
        status: TicketStatus.queued,
      );

      // Try to submit directly, fallback to queue
      try {
        await ref.read(ticketsProvider.notifier).submitTicket(ticket);
        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        // Queue for offline sync
        await _ticketQueueService.queueTicket(ticket);
        if (mounted) {
          _showQueuedDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال التذكرة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('تم الإرسال بنجاح!'),
        content: const Text('تم إرسال تذكرة المبيعات بنجاح.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('إنشاء تذكرة جديدة'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  void _showQueuedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_queue, color: Colors.orange, size: 48),
        title: const Text('تم الحفظ في الانتظار'),
        content: const Text(
          'تم حفظ التذكرة وسيتم إرسالها عند توفر الاتصال بالإنترنت.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('إنشاء تذكرة جديدة'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _formData = null;
      _selectedProducts = [];
    });
    _captureLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء تذكرة مبيعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.horizontal, // Horizontal looks better usually
        onStepContinue: _currentStep < 2
            ? () => setState(() => _currentStep++)
            : null,
        onStepCancel: _currentStep > 0
            ? () => setState(() => _currentStep--)
            : null,
        controlsBuilder: (context, details) {
          if (_currentStep == 2) {
            return const SizedBox.shrink(); // Custom controls in review step
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (details.onStepCancel != null && _currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('رجوع'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Client Details
          Step(
            title: const Text('العميل'),
            subtitle: _formData != null ? Text(_formData!.clientName) : null,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                SalesTicketForm(
                  isLoading: _isSubmitting,
                  onSubmit: (data) {
                    setState(() {
                      _formData = data;
                      _currentStep = 1;
                    });
                  },
                ),
              ],
            ),
          ),

          // Step 2: Select Products
          Step(
            title: const Text('المنتجات'),
            subtitle: _selectedProducts.isNotEmpty
                ? Text('${_selectedProducts.length} منتجات')
                : null,
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                ProductSelector(
                  initialSelection: _selectedProducts,
                  onChanged: (products) {
                    setState(() => _selectedProducts = products);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('رجوع'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => setState(() => _currentStep = 2),
                      child: const Text('متابعة للمراجعة'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Step 3: Review & Submit
          Step(
            title: const Text('المراجعة'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _currentLocation != null
                                  ? Icons.location_on
                                  : Icons.location_off,
                              color: _currentLocation != null
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الموقع',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            if (_isCapturingLocation)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              TextButton(
                                onPressed: _captureLocation,
                                child: const Text('تحديث'),
                              ),
                          ],
                        ),
                        if (_currentLocation != null)
                          Text(
                            '${_currentLocation!.latitude.toStringAsFixed(6)}, '
                            '${_currentLocation!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (_locationError != null)
                          Text(
                            _locationError!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Summary
                if (_formData != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ملخص الطلب',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _SummaryRow('العميل', _formData!.clientName),
                          _SummaryRow('الهاتف', _formData!.clientPhone),
                          if (_formData!.workerNotes.isNotEmpty)
                            _SummaryRow('ملاحظات', _formData!.workerNotes),
                          if (_selectedProducts.isNotEmpty) ...[
                            const Divider(),
                            Text(
                              'المنتجات (${_selectedProducts.length})',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...(_selectedProducts.map(
                              (p) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${p.product.name} x${p.quantity}'),
                                    Text(
                                      CurrencyFormatter.formatEGP(p.totalPrice),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الإجمالي',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  CurrencyFormatter.formatEGP(
                                    _selectedProducts.fold<double>(
                                      0,
                                      (sum, p) => sum + p.totalPrice,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() => _currentStep = 1),
                        child: const Text('رجوع'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting || _currentLocation == null
                            ? null
                            : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isSubmitting ? 'جاري الإرسال...' : 'إرسال التذكرة',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
