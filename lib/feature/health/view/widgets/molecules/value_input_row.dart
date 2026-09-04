import 'package:flutter/material.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/validators.dart';

class ValueKindOption<T> {
  const ValueKindOption({required this.value, required this.label});

  final T value;
  final String label;
}

class ValueInputRow<T> extends StatelessWidget {
  const ValueInputRow({
    super.key,
    required this.fieldNameController,
    required this.valueController,
    required this.kind,
    required this.kindOptions,
    required this.onKindChanged,
    required this.valueValidator,
    this.onRemove,
  });

  final TextEditingController fieldNameController;
  final TextEditingController valueController;
  final T kind;
  final List<ValueKindOption<T>> kindOptions;
  final ValueChanged<T> onKindChanged;
  final String? Function(String? value) valueValidator;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: fieldNameController,
            decoration: const InputDecoration(labelText: 'Field name'),
            validator: requiredFieldValidator,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: DropdownButtonFormField<T>(
            initialValue: kind,
            decoration: const InputDecoration(labelText: 'Type'),
            items: kindOptions.map((option) {
              return DropdownMenuItem(value: option.value, child: Text(option.label));
            }).toList(),
            onChanged: (value) {
              if (value != null) onKindChanged(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: valueController,
            decoration: const InputDecoration(labelText: 'Value'),
            validator: valueValidator,
          ),
        ),
        if (onRemove != null)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Remove',
          ),
      ],
    );
  }
}
