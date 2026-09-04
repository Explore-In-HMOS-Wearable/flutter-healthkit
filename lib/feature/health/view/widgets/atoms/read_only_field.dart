import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  const ReadOnlyField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value.isEmpty ? '-' : value,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
