import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/constants/health_form_defaults.dart';
import 'package:flutter_healthkit/core/model/health_data_type.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_request_model.dart';
import 'package:flutter_healthkit/feature/health/notifier/insert_health_records_notifier.dart';
import 'package:flutter_healthkit/feature/health/util/nanoseconds.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/date_time_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/section_label.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/validators.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/data_collector_picker_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/value_input_row.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/organisms/health_form_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _selectableDataTypes = HealthDataType.values
    .where((t) => t.dataTypeName.startsWith(healthRecordTypePrefix))
    .toList();

final _defaultStart = DateTime.now().subtract(const Duration(days: 7));
final _defaultEnd = DateTime.now();

enum _ValueKind { integer, long, string }

const _valueKindOptions = [
  ValueKindOption(value: _ValueKind.integer, label: 'Int'),
  ValueKindOption(value: _ValueKind.long, label: 'Long'),
  ValueKindOption(value: _ValueKind.string, label: 'String'),
];

String? _valueValidator(_ValueKind kind, String? value) {
  if (kind == _ValueKind.string) return null;
  return int.tryParse(value?.trim() ?? '') == null ? 'Enter a whole number' : null;
}

class _ValueRow {
  _ValueRow({required String fieldName, required this.kind, required String value})
    : fieldNameController = TextEditingController(text: fieldName),
      valueController = TextEditingController(text: value);

  final TextEditingController fieldNameController;
  final TextEditingController valueController;
  _ValueKind kind;

  void dispose() {
    fieldNameController.dispose();
    valueController.dispose();
  }

  Value toValue() {
    final raw = valueController.text.trim();
    return Value(
      fieldName: fieldNameController.text.trim(),
      integerValue: kind == _ValueKind.integer ? int.tryParse(raw) : null,
      longValue: kind == _ValueKind.long ? int.tryParse(raw) : null,
      stringValue: kind == _ValueKind.string ? raw : null,
    );
  }
}

class _SubDataRelationRow {
  _SubDataRelationRow({
    required this.startTime,
    required this.endTime,
    required String dataTypeName,
    required String dataCollectorId,
  }) : dataTypeNameController = TextEditingController(text: dataTypeName),
       dataCollectorIdController = TextEditingController(text: dataCollectorId);

  DateTime startTime;
  DateTime endTime;
  final TextEditingController dataTypeNameController;
  final TextEditingController dataCollectorIdController;

  void dispose() {
    dataTypeNameController.dispose();
    dataCollectorIdController.dispose();
  }

  SubDataRelation toSubDataRelation() => SubDataRelation(
    startTime: toNanoseconds(startTime),
    endTime: toNanoseconds(endTime),
    dataTypeName: dataTypeNameController.text.trim(),
    dataCollectorId: dataCollectorIdController.text.trim(),
  );
}

class InsertHealthRecordsSheet extends ConsumerStatefulWidget {
  const InsertHealthRecordsSheet({super.key});

  @override
  ConsumerState<InsertHealthRecordsSheet> createState() =>
      _InsertHealthRecordsSheetState();
}

class _InsertHealthRecordsSheetState
    extends ConsumerState<InsertHealthRecordsSheet> {
  final _formSecret = GlobalKey<FormState>();

  String? _dataCollectorId;
  HealthDataType? _dataType = _selectableDataTypes.isNotEmpty
      ? _selectableDataTypes.first
      : null;

  var _startTime = _defaultStart;
  var _endTime = _defaultEnd;

  final _valueRows = [
    _ValueRow(
      fieldName: 'fall_asleep_time',
      kind: _ValueKind.long,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'wakeup_time',
      kind: _ValueKind.long,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'light_sleep_time',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'deep_sleep_time',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'dream_time',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'awake_time',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'all_sleep_time',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'wakeup_count',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'deep_sleep_part',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'sleep_score',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'go_bed_time',
      kind: _ValueKind.long,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
    _ValueRow(
      fieldName: 'sleep_type',
      kind: _ValueKind.integer,
      value: HealthFormDefaults.placeholderNumericValue,
    ),
  ];

  final _subDataRelationRows = [
    _SubDataRelationRow(
      startTime: _defaultStart,
      endTime: _defaultEnd,
      dataTypeName: HealthFormDefaults.sleepFragmentDataType,
      dataCollectorId: HealthFormDefaults.sleepSubDataCollectorId,
    ),
  ];

  bool _hasSubmitted = false;
  String? _errorText;

  @override
  void dispose() {
    for (final row in _valueRows) {
      row.dispose();
    }
    for (final row in _subDataRelationRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addValueRow() {
    setState(() {
      _valueRows.add(
        _ValueRow(fieldName: '', kind: _ValueKind.integer, value: ''),
      );
    });
  }

  void _removeValueRow(_ValueRow row) {
    setState(() {
      _valueRows.remove(row);
      row.dispose();
    });
  }

  void _addSubDataRelationRow() {
    setState(() {
      _subDataRelationRows.add(
        _SubDataRelationRow(
          startTime: _startTime,
          endTime: _endTime,
          dataTypeName: '',
          dataCollectorId: '',
        ),
      );
    });
  }

  void _removeSubDataRelationRow(_SubDataRelationRow row) {
    setState(() {
      _subDataRelationRows.remove(row);
      row.dispose();
    });
  }

  void _submit() {
    if (!_formSecret.currentState!.validate()) return;

    setState(() {
      _hasSubmitted = true;
      _errorText = null;
    });

    ref.read(insertHealthRecordsNotifierProvider.notifier).submit(
      dataCollectorId: _dataCollectorId!,
      request: GeneralDataCollectorPatchRequestModel(
        healthRecords: [
          HealthRecords(
            dataTypeName: _dataType!.dataTypeName,
            startTime: toNanoseconds(_startTime),
            endTime: toNanoseconds(_endTime),
            value: _valueRows.map((row) => row.toValue()).toList(),
            subDataRelation: _subDataRelationRows.isEmpty
                ? null
                : _subDataRelationRows
                      .map((row) => row.toSubDataRelation())
                      .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(insertHealthRecordsNotifierProvider, (previous, next) {
      if (!_hasSubmitted || next.isLoading) return;
      next.when(
        data: (response) {
          if (response == null) {
            const message = 'Request failed. Please try again.';
            setState(() => _errorText = message);
            showHealthErrorSnackBar(context, message);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health record inserted.')),
          );
          Navigator.of(context).maybePop();
        },
        error: (error, _) {
          setState(() => _errorText = error.toString());
          showHealthErrorSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    final state = ref.watch(insertHealthRecordsNotifierProvider);

    return HealthFormSheet(
      title: 'Insert Health Records',
      formKey: _formSecret,
      isSubmitting: state.isLoading,
      errorText: _errorText,
      onSubmit: _submit,
      submitLabel: 'Insert',
      children: [
        DataCollectorPickerField(
          selectedId: _dataCollectorId,
          onSelected: (collector) =>
              setState(() => _dataCollectorId = collector.collectorId),
          filter: (collector) =>
              (collector.collectorDataType?.name ?? '').startsWith(healthRecordTypePrefix),
        ),
        const HealthFormSectionLabel('DATA TYPE'),
        DropdownButtonFormField<HealthDataType>(
          initialValue: _dataType,
          decoration: const InputDecoration(labelText: 'Data type'),
          items: _selectableDataTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type.dataTypeName));
          }).toList(),
          onChanged: (type) => setState(() => _dataType = type),
          validator: (value) => value == null ? 'Required' : null,
        ),
        const HealthFormSectionLabel('TIME RANGE'),
        DateTimeField(
          label: 'Start time',
          value: _startTime,
          onChanged: (value) => setState(() => _startTime = value),
        ),
        const SizedBox(height: 12),
        DateTimeField(
          label: 'End time',
          value: _endTime,
          onChanged: (value) => setState(() => _endTime = value),
        ),
        const HealthFormSectionLabel('VALUES'),
        for (final row in _valueRows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ValueInputRow<_ValueKind>(
              fieldNameController: row.fieldNameController,
              valueController: row.valueController,
              kind: row.kind,
              kindOptions: _valueKindOptions,
              onKindChanged: (kind) => row.kind = kind,
              valueValidator: (value) => _valueValidator(row.kind, value),
              onRemove: () => _removeValueRow(row),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addValueRow,
            icon: const Icon(Icons.add),
            label: const Text('Add value'),
          ),
        ),
        const HealthFormSectionLabel('SUB DATA RELATION (OPTIONAL)'),
        for (final row in _subDataRelationRows)
          _SubDataRelationRowField(
            row: row,
            onRemove: () => _removeSubDataRelationRow(row),
            onChanged: () => setState(() {}),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addSubDataRelationRow,
            icon: const Icon(Icons.add),
            label: const Text('Add sub data relation'),
          ),
        ),
      ],
    );
  }
}

class _SubDataRelationRowField extends StatelessWidget {
  const _SubDataRelationRowField({
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  final _SubDataRelationRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.dataTypeNameController,
                  decoration: const InputDecoration(labelText: 'Data type name'),
                  validator: requiredFieldValidator,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row.dataCollectorIdController,
            decoration: const InputDecoration(labelText: 'Data collector ID'),
            validator: requiredFieldValidator,
          ),
          const SizedBox(height: 8),
          DateTimeField(
            label: 'Start time',
            value: row.startTime,
            onChanged: (value) {
              row.startTime = value;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          DateTimeField(
            label: 'End time',
            value: row.endTime,
            onChanged: (value) {
              row.endTime = value;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
