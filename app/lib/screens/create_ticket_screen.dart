import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui'; // For BackdropFilter

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
  String? _currentAddress;
  bool _isCapturingLocation = false;
  String? _locationError;

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
      _currentAddress = null;
    });

    try {
      final position = await _geolocationService.getCurrentLocation();

      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          // Try to find interesting landmarks
          final Set<String> potentialLandmarks = {};
          for (final p in placemarks.take(5)) {
            if (p.name != null && p.name!.isNotEmpty) {
              final name = p.name!;
              // Filter out numeric names (house numbers) and duplicates
              if (!RegExp(r'^[\d٠-٩]').hasMatch(name) &&
                  name != p.street &&
                  name != p.subLocality &&
                  name != p.locality) {
                potentialLandmarks.add(name);
              }
            }
          }

          final components = [
            ...potentialLandmarks,
            place.name, // Include main name (might be house number, but useful)
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ].where((element) => element != null && element.isNotEmpty).toSet().toList();

          address = components.join('، ');
        }
      } catch (e) {
        // Geocoding failed, silently ignore
      }

      if (mounted) {
        setState(() {
          _currentLocation = position;
          _currentAddress = address;
          _isCapturingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isCapturingLocation = false;
        });
      }
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
        laundryName: _formData!.laundryName,
        workerNotes: _formData!.workerNotes,
        clientNotes: _formData!.clientNotes,
        saleAmount: calculatedSaleAmount,
        workerId: user.userId,
        workerName: user.name,
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
            content: Text('فشل إرسال الزيارة: $e'),
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
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withValues(alpha: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.green,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'تم الإرسال بنجاح',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تم إرسال الزيارة بنجاح',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _resetForm();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'إنشاء جديدة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              'تم',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          'تم حفظ الزيارة وسيتم إرسالها عند توفر الاتصال بالإنترنت.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('إنشاء زيارة جديدة'),
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
      _currentAddress = null;
    });
    _captureLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 141, 17, 17), Color(0xFF6E0A0A)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'إنشاء زيارة مبيعات',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Theme(
        data: ThemeData.light().copyWith(
          primaryColor: AppTheme.primaryRed,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          canvasColor: const Color(0xFFF8F9FA),
          colorScheme: ColorScheme.light(
            primary: AppTheme.primaryRed,
            secondary: AppTheme.primaryRed,
            surface: const Color(0xFFF8F9FA),
            onSurface: const Color(0xFF1F2937),
          ),
          textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
        ),
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.horizontal,
          elevation: 0,
          physics: const ClampingScrollPhysics(),
          onStepContinue: _currentStep < 2
              ? () => setState(() => _currentStep++)
              : null,
          onStepCancel: _currentStep > 0
              ? () => setState(() => _currentStep--)
              : null,
          controlsBuilder: (context, details) {
            return const SizedBox.shrink(); // Use custom controls in step content
          },
          steps: [
            // Step 1: Client Details
            Step(
              title: Text(
                'العميل',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: _formData != null
                  ? Text(
                      _formData!.clientName,
                      style: GoogleFonts.cairo(fontSize: 12),
                    )
                  : null,
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SalesTicketForm(
                  isLoading: _isSubmitting,
                  onSubmit: (data) {
                    setState(() {
                      _formData = data;
                      _currentStep = 1;
                    });
                  },
                ),
              ),
            ),

            // Step 2: Select Products
            Step(
              title: Text(
                'المنتجات',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: _selectedProducts.isNotEmpty
                  ? Text(
                      '${_selectedProducts.length} منتجات',
                      style: GoogleFonts.cairo(fontSize: 12),
                    )
                  : null,
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProductSelector(
                      initialSelection: _selectedProducts,
                      onChanged: (products) {
                        setState(() => _selectedProducts = products);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentStep = 0),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'رجوع',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _currentStep = 2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'متابعة للمراجعة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Step 3: Review & Submit
            Step(
              title: Text(
                'المراجعة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _currentLocation != null
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _currentLocation != null
                                ? Icons.location_on
                                : Icons.location_off,
                            color: _currentLocation != null
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الموقع',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_currentAddress != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _currentAddress!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              if (_currentLocation != null)
                                Text(
                                  'الإحداثيات: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              if (_locationError != null)
                                Text(
                                  _locationError!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_isCapturingLocation)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton(
                            onPressed: _captureLocation,
                            child: Text(
                              'تحديث',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),

                    // Order Summary
                    if (_formData != null) ...[
                      Text(
                        'ملخص الطلب',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow('العميل', _formData!.clientName),
                      // Laundry Name Row
                      if (_formData!.laundryName.isNotEmpty)
                        _SummaryRow('المغسلة', _formData!.laundryName),
                      _SummaryRow('الهاتف', _formData!.clientPhone),
                      if (_formData!.workerNotes.isNotEmpty)
                        _SummaryRow('ملاحظات المندوب', _formData!.workerNotes),
                      if (_formData!.clientNotes.isNotEmpty)
                        _SummaryRow('ملاحظات العميل', _formData!.clientNotes),

                      if (_selectedProducts.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Text(
                          'المنتجات (${_selectedProducts.length})',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ...(_selectedProducts.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${p.quantity}x',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRed,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          p.product.name,
                                          style: GoogleFonts.cairo(
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.formatEGP(
                                          p.totalPrice,
                                        ),
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.deepCharcoal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الإجمالي',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.deepCharcoal,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatEGP(
                                      _selectedProducts.fold<double>(
                                        0,
                                        (sum, p) => sum + p.totalPrice,
                                      ),
                                    ),
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() => _currentStep = 1),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'رجوع',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting || _currentLocation == null
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            label: Text(
                              _isSubmitting
                                  ? 'جاري الإرسال...'
                                  : 'إرسال الزيارة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
