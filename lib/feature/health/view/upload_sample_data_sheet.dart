import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/constants/health_form_defaults.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart'
    hide Value;
import 'package:flutter_healthkit/core/network/model/sample_data_upload_request_model.dart';
import 'package:flutter_healthkit/feature/health/notifier/upload_sample_data_notifier.dart';
import 'package:flutter_healthkit/feature/health/util/nanoseconds.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/date_time_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/read_only_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/section_label.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/data_collector_picker_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/value_input_row.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/organisms/health_form_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _defaultStart = DateTime.now().subtract(const Duration(days: 7));
final _defaultEnd = DateTime.now();

enum _ValueKind { integer, float, string }

const _valueKindOptions = [
  ValueKindOption(value: _ValueKind.integer, label: 'Integer'),
  ValueKindOption(value: _ValueKind.float, label: 'Float'),
  ValueKindOption(value: _ValueKind.string, label: 'String'),
];

String? _valueValidator(_ValueKind kind, String? value) {
  final raw = value?.trim() ?? '';
  if (kind == _ValueKind.string) return raw.isEmpty ? 'Required' : null;
  return num.tryParse(raw) == null ? 'Enter a number' : null;
}

class UploadSampleDataSheet extends ConsumerStatefulWidget {
  const UploadSampleDataSheet({super.key});

  @override
  ConsumerState<UploadSampleDataSheet> createState() =>
      _UploadSampleDataSheetState();
}

class _UploadSampleDataSheetState extends ConsumerState<UploadSampleDataSheet> {
  final _formSecret = GlobalKey<FormState>();

  GeneralDataCollectorResponseModel? _selectedCollector;

  final _fieldName = TextEditingController(text: HealthFormDefaults.sampleFieldName);
  final _value = TextEditingController(text: HealthFormDefaults.sampleValue);
  var _valueKind = _ValueKind.integer;

  var _windowStart = _defaultStart;
  var _windowEnd = _defaultEnd;
  var _sampleStart = _defaultStart;
  var _sampleEnd = _defaultEnd;

  bool _hasSubmitted = false;
  String? _errorText;

  String get _sampleSetId =>
      '${toNanoseconds(_windowStart)}-${toNanoseconds(_windowEnd)}';

  String get _dataTypeName => _selectedCollector?.collectorDataType?.name ?? '';

  @override
  void dispose() {
    _fieldName.dispose();
    _value.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formSecret.currentState!.validate()) return;

    setState(() {
      _hasSubmitted = true;
      _errorText = null;
    });

    final dataCollectorId = _selectedCollector!.collectorId!;
    ref.read(uploadSampleDataNotifierProvider.notifier).submit(
      dataCollectorId: dataCollectorId,
      sampleSetId: _sampleSetId,
      request: SampleDataUploadPatchRequestModel(
        dataCollectorId: dataCollectorId,
        startTime: toNanoseconds(_windowStart),
        endTime: toNanoseconds(_windowEnd),
        samplePoints: [
          SamplePoints(
            dataTypeName: _dataTypeName,
            startTime: toNanoseconds(_sampleStart),
            endTime: toNanoseconds(_sampleEnd),
            value: [
              Value(
                fieldName: _fieldName.text.trim(),
                integerValue: _valueKind == _ValueKind.integer
                    ? int.parse(_value.text.trim())
                    : null,
                floatValue: _valueKind == _ValueKind.float
                    ? num.parse(_value.text.trim())
                    : null,
                stringValue:
                    _valueKind == _ValueKind.string ? _value.text.trim() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(uploadSampleDataNotifierProvider, (previous, next) {
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
            const SnackBar(content: Text('Sample data uploaded.')),
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

    final state = ref.watch(uploadSampleDataNotifierProvider);

    return HealthFormSheet(
      title: 'Upload Sample Data',
      formKey: _formSecret,
      isSubmitting: state.isLoading,
      errorText: _errorText,
      onSubmit: _submit,
      submitLabel: 'Upload',
      children: [
        DataCollectorPickerField(
          selectedId: _selectedCollector?.collectorId,
          onSelected: (collector) => setState(() => _selectedCollector = collector),
        ),
        const SizedBox(height: 12),
        ReadOnlyField(label: 'Data type', value: _dataTypeName),
        const HealthFormSectionLabel('UPLOAD WINDOW'),
        DateTimeField(
          label: 'Window start',
          value: _windowStart,
          onChanged: (value) => setState(() => _windowStart = value),
        ),
        const SizedBox(height: 12),
        DateTimeField(
          label: 'Window end',
          value: _windowEnd,
          onChanged: (value) => setState(() => _windowEnd = value),
        ),
        const SizedBox(height: 12),
        ReadOnlyField(label: 'Sample set ID', value: _sampleSetId),
        const HealthFormSectionLabel('SAMPLE POINT RANGE'),
        DateTimeField(
          label: 'Sample start',
          value: _sampleStart,
          onChanged: (value) => setState(() => _sampleStart = value),
        ),
        const SizedBox(height: 12),
        DateTimeField(
          label: 'Sample end',
          value: _sampleEnd,
          onChanged: (value) => setState(() => _sampleEnd = value),
        ),
        const HealthFormSectionLabel('VALUE'),
        ValueInputRow<_ValueKind>(
          fieldNameController: _fieldName,
          valueController: _value,
          kind: _valueKind,
          kindOptions: _valueKindOptions,
          onKindChanged: (kind) => setState(() => _valueKind = kind),
          valueValidator: (value) => _valueValidator(_valueKind, value),
        ),
      ],
    );
  }
}
