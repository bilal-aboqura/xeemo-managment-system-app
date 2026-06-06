import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// Form widget for capturing sales ticket information
class SalesTicketForm extends StatefulWidget {
  /// Callback when form is submitted
  final void Function(SalesTicketFormData data) onSubmit;

  /// Whether the form is in loading state
  final bool isLoading;

  /// Pre-populated client name
  final String? initialClientName;

  /// Pre-populated client phone
  final String? initialClientPhone;

  const SalesTicketForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialClientName,
    this.initialClientPhone,
  });

  @override
  State<SalesTicketForm> createState() => _SalesTicketFormState();
}

class _SalesTicketFormState extends State<SalesTicketForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientPhoneController;
  late final TextEditingController _workerNotesController;
  late final TextEditingController _clientNotesController;
  late final TextEditingController _laundryNameController;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(
      text: widget.initialClientName,
    );
    _clientPhoneController = TextEditingController(
      text: widget.initialClientPhone,
    );
    _workerNotesController = TextEditingController();
    _clientNotesController = TextEditingController();
    _laundryNameController = TextEditingController();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _workerNotesController.dispose();
    _clientNotesController.dispose();
    _laundryNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = SalesTicketFormData(
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      laundryName: _laundryNameController.text.trim(),
      workerNotes: _workerNotesController.text.trim(),
      clientNotes: _clientNotesController.text.trim(),
    );

    widget.onSubmit(data);
  }

  void _clearForm() {
    _clientNameController.clear();
    _clientPhoneController.clear();
    _laundryNameController.clear();
    _workerNotesController.clear();
    _clientNotesController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: GoogleFonts.cairo(color: const Color(0xFF6B7280)),
      hintStyle: GoogleFonts.cairo(color: const Color(0xFF9CA3AF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Client Name
          TextFormField(
            controller: _clientNameController,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
            decoration: inputDecoration.copyWith(
              labelText: 'اسم العميل *',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Color(0xFF6B7280),
              ),
              hintText: 'أدخل اسم العميل',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم العميل مطلوب';
              }
              if (value.trim().length < 2) {
                return 'الاسم يجب أن يكون حرفين على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Laundry Name
          TextFormField(
            controller: _laundryNameController,
            enabled: !widget.isLoading,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
            decoration: inputDecoration.copyWith(
              labelText: 'اسم المغسلة *',
              counterText: "",
              prefixIcon: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF6B7280),
              ),
              hintText: 'أدخل اسم المغسلة',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم المغسلة مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Client Phone
          TextFormField(
            controller: _clientPhoneController,
            enabled: !widget.isLoading,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.cairo(),
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: inputDecoration.copyWith(
              labelText: 'رقم الهاتف *',
              counterText: "",
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: Color(0xFF6B7280),
              ),
              hintText: '01xxxxxxxxx',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'رقم الهاتف مطلوب';
              }
              if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                return 'رقم الهاتف يجب أن يكون 11 رقم ويبدأ ب 01';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Worker Notes
          TextFormField(
            controller: _workerNotesController,
            enabled: !widget.isLoading,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
            decoration: inputDecoration.copyWith(
              labelText: 'ملاحظات المندوب',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.note_alt_outlined, color: Color(0xFF6B7280)),
              ),
              hintText: 'أضف أي ملاحظات حول عملية البيع...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // Client Notes
          TextFormField(
            controller: _clientNotesController,
            enabled: !widget.isLoading,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
            decoration: inputDecoration.copyWith(
              labelText: 'ملاحظات العميل',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(
                  Icons.speaker_notes_outlined,
                  color: Color(0xFF6B7280),
                ),
              ),
              hintText: 'أي ملاحظات من العميل...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : _clearForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'مسح',
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
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'متابعة',
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
    );
  }
}

/// Data from the sales ticket form
class SalesTicketFormData {
  final String clientName;
  final String clientPhone;
  final String laundryName;
  final String workerNotes;
  final String clientNotes;

  SalesTicketFormData({
    required this.clientName,
    required this.clientPhone,
    required this.laundryName,
    required this.workerNotes,
    required this.clientNotes,
  });
}
