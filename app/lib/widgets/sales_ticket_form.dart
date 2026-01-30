import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late final TextEditingController _saleAmountController;

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
    _saleAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _workerNotesController.dispose();
    _clientNotesController.dispose();
    _saleAmountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = SalesTicketFormData(
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      workerNotes: _workerNotesController.text.trim(),
      clientNotes: _clientNotesController.text.trim(),
      saleAmount: double.tryParse(_saleAmountController.text) ?? 0.0,
    );

    widget.onSubmit(data);
  }

  void _clearForm() {
    _clientNameController.clear();
    _clientPhoneController.clear();
    _workerNotesController.clear();
    _clientNotesController.clear();
    _saleAmountController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: const InputDecoration(
              labelText: 'اسم العميل *',
              prefixIcon: Icon(Icons.person_outline),
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

          // Client Phone
          TextFormField(
            controller: _clientPhoneController,
            enabled: !widget.isLoading,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.right,
            textDirection: TextDirection
                .ltr, // Phone numbers are LTR usually, but labels RTL
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
            ],
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف *',
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: '01xxxxxxxxx',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'رقم الهاتف مطلوب';
              }
              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (digitsOnly.length < 7) {
                return 'يرجى إدخال رقم هاتف صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Sale Amount
          TextFormField(
            controller: _saleAmountController,
            enabled: !widget.isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr, // Numbers LTR
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'مبلغ البيع *',
              prefixIcon: Icon(Icons.attach_money),
              suffixText: 'ج.م',
              hintText: '0.00',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'مبلغ البيع مطلوب';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 0) {
                return 'يرجى إدخال مبلغ صحيح';
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
            decoration: const InputDecoration(
              labelText: 'ملاحظات الموظف',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.note_alt_outlined),
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
            decoration: const InputDecoration(
              labelText: 'ملاحظات العميل',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.speaker_notes_outlined),
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
                  child: const Text('مسح'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('متابعة'),
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
  final String workerNotes;
  final String clientNotes;
  final double saleAmount;

  SalesTicketFormData({
    required this.clientName,
    required this.clientPhone,
    required this.workerNotes,
    required this.clientNotes,
    required this.saleAmount,
  });
}
