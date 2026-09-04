import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/constants/health_form_defaults.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_request_model.dart';
import 'package:flutter_healthkit/feature/health/notifier/create_data_collector_notifier.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/section_label.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/validators.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/data_type_chip_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/organisms/health_form_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateDataCollectorSheet extends ConsumerStatefulWidget {
  const CreateDataCollectorSheet({super.key});

  @override
  ConsumerState<CreateDataCollectorSheet> createState() =>
      _CreateDataCollectorSheetState();
}

class _CreateDataCollectorSheetState
    extends ConsumerState<CreateDataCollectorSheet> {
  final _formSecret = GlobalKey<FormState>();

  final _collectorName = TextEditingController(text: HealthFormDefaults.collectorName);
  final _collectorType = TextEditingController(text: HealthFormDefaults.collectorType);
  final _dataTypeName = TextEditingController(
    text: HealthFormDefaults.stepsDeltaDataType,
  );
  final _appName = TextEditingController(text: HealthFormDefaults.appName);
  final _appDesc = TextEditingController(text: HealthFormDefaults.appDescription);
  final _appVersion = TextEditingController(text: HealthFormDefaults.appVersion);
  final _manufacturer = TextEditingController(text: HealthFormDefaults.deviceManufacturer);
  final _modelNum = TextEditingController(text: HealthFormDefaults.deviceModelNumber);
  final _devType = TextEditingController(text: HealthFormDefaults.deviceType);
  final _uniqueId = TextEditingController(text: HealthFormDefaults.deviceUniqueId);
  final _deviceVersion = TextEditingController(text: HealthFormDefaults.deviceVersion);

  bool _hasSubmitted = false;
  String? _errorText;

  @override
  void dispose() {
    _collectorName.dispose();
    _collectorType.dispose();
    _dataTypeName.dispose();
    _appName.dispose();
    _appDesc.dispose();
    _appVersion.dispose();
    _manufacturer.dispose();
    _modelNum.dispose();
    _devType.dispose();
    _uniqueId.dispose();
    _deviceVersion.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formSecret.currentState!.validate()) return;

    setState(() {
      _hasSubmitted = true;
      _errorText = null;
    });

    ref.read(createDataCollectorNotifierProvider.notifier).submit(
      GeneralDataCollectorRequestModel(
        collectorName: _collectorName.text.trim(),
        collectorType: _collectorType.text.trim(),
        collectorDataType: CollectorDataType(name: _dataTypeName.text.trim()),
        appInfo: AppInfo(
          appName: _appName.text.trim(),
          desc: _appDesc.text.trim(),
          appVersion: _appVersion.text.trim(),
        ),
        deviceInfo: DeviceInfo(
          manufacturer: _manufacturer.text.trim(),
          modelNum: _modelNum.text.trim(),
          devType: _devType.text.trim(),
          uniqueId: _uniqueId.text.trim(),
          version: _deviceVersion.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createDataCollectorNotifierProvider, (previous, next) {
      if (!_hasSubmitted || next.isLoading) return;
      next.when(
        data: (response) {
          if (response == null) {
            const message = 'Request failed. Please try again.';
            setState(() => _errorText = message);
            showHealthErrorSnackBar(context, message);
            return;
          }
          ref.read(dataCollectorsNotifierProvider.notifier).addOrUpdate(response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Collector created: ${response.collectorId}')),
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

    final state = ref.watch(createDataCollectorNotifierProvider);

    return HealthFormSheet(
      title: 'Create Data Collector',
      formKey: _formSecret,
      isSubmitting: state.isLoading,
      errorText: _errorText,
      onSubmit: _submit,
      submitLabel: 'Create',
      children: [
        TextFormField(
          controller: _collectorName,
          decoration: const InputDecoration(labelText: 'Collector name'),
          validator: requiredFieldValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _collectorType,
          decoration: const InputDecoration(labelText: 'Collector type'),
          validator: requiredFieldValidator,
        ),
        const HealthFormSectionLabel('DATA TYPE'),
        DataTypeChipField(controller: _dataTypeName),
        const HealthFormSectionLabel('APP INFO'),
        TextFormField(
          controller: _appName,
          decoration: const InputDecoration(labelText: 'App name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _appDesc,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _appVersion,
          decoration: const InputDecoration(labelText: 'App version'),
        ),
        const HealthFormSectionLabel('DEVICE INFO'),
        TextFormField(
          controller: _manufacturer,
          decoration: const InputDecoration(labelText: 'Manufacturer'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _modelNum,
          decoration: const InputDecoration(labelText: 'Model number'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _devType,
          decoration: const InputDecoration(labelText: 'Device type'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _uniqueId,
          decoration: const InputDecoration(labelText: 'Unique ID'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _deviceVersion,
          decoration: const InputDecoration(labelText: 'Device version'),
        ),
      ],
    );
  }
}
