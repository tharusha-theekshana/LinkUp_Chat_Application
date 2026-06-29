import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AppDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;
  final void Function(DateTime)? onDateSelected;

  const AppDatePicker({
    super.key,
    required this.controller,
    required this.label,
    this.hintText = 'Select date',
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.onDateSelected,
  });

  static const Color _primaryColor =AppTheme.primaryColor;

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: AppTheme.cardColor,
              onSurface: AppTheme.textPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _formatDate(picked);
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(context),
          validator: validator,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            prefixIcon: Icon(
              Icons.cake_outlined,
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
            suffixIcon: Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
            filled: true,
            fillColor: AppTheme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondaryColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondaryColor,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
            errorStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
        ),
      ],
    );
  }
}