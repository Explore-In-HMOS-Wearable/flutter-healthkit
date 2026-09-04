import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/model/health_data_type.dart';

class DataTypeChipField extends StatelessWidget {
  const DataTypeChipField({
    super.key,
    required this.controller,
    this.label = 'Data type name',
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Wrap(
              spacing: 8,
              children: HealthDataType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name),
                  selected: controller.text == type.dataTypeName,
                  onSelected: (_) {
                    controller.text = type.dataTypeName;
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
