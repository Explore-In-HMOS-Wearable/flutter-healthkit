import 'package:flutter/material.dart';

class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final defaultLastDate = DateTime.now().add(const Duration(days: 365));
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(value.year < 2000 ? value.year : 2000),
      lastDate: value.isAfter(defaultLastDate) ? value : defaultLastDate,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          '${value.toLocal()}'.substring(0, 16),
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}
