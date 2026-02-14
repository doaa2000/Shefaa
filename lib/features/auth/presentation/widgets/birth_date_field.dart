import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';

class BirthDateField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onDateSelected;

  const BirthDateField({
    super.key,
    this.controller,
    this.hintText = "تاريخ الميلاد",
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
  });

  @override
  State<BirthDateField> createState() => _BirthDateFieldState();
}

class _BirthDateFieldState extends State<BirthDateField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime(2000),
      firstDate: widget.firstDate ?? DateTime(1950),
      lastDate: widget.lastDate ?? DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      _controller.text = formattedDate;

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: widget.hintText,
      controller: _controller,
      readOnly: true,
      onTap: _pickDate,
      isPassword: false,
    );
  }
}
