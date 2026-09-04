import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/feature/health/notifier/update_data_collector_notifier.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/section_label.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/validators.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/data_collector_picker_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/molecules/data_type_chip_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/organisms/health_form_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateDataCollectorSheet extends ConsumerStatefulWidget {
  const UpdateDataCollectorSheet({super.key});

  @override
  ConsumerState<UpdateDataCollectorSheet> createState() =>
      _UpdateDataCollectorSheetState();
}

class _UpdateDataCollectorSheetState
    extends ConsumerState<UpdateDataCollectorSheet> {
  final _formSecret = GlobalKey<FormState>();

  GeneralDataCollectorResponseModel? _selectedCollector;

  final _collectorName = TextEditingController();
  final _collectorType = TextEditingController();
  final _dataTypeName = TextEditingController();
  final _clientId = TextEditingController();
  final _appPackageName = TextEditingController();
  final _appName = TextEditingController();
  final _appDesc = TextEditingController();
  final _appVersion = TextEditingController();
  final _manufacturer = TextEditingController();
  final _modelNum = TextEditingController();
  final _devType = TextEditingController();
  final _uniqueId = TextEditingController();
  final _deviceVersion = TextEditingController();

  bool _hasSubmitted = false;
  String? _errorText;

  @override
  void dispose() {
    _collectorName.dispose();
    _collectorType.dispose();
    _dataTypeName.dispose();
    _clientId.dispose();
    _appPackageName.dispose();
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

  void _onCollectorSelected(GeneralDataCollectorResponseModel collector) {
    setState(() {
      _selectedCollector = collector;
      _collectorName.text = collector.collectorName ?? '';
      _collectorType.text = collector.collectorType ?? '';
      _dataTypeName.text = collector.collectorDataType?.name ?? '';
      _clientId.text = collector.appInfo?.clientId ?? '';
      _appPackageName.text = collector.appInfo?.appPackageName ?? '';
      _appName.text = collector.appInfo?.appName ?? '';
      _appDesc.text = collector.appInfo?.desc ?? '';
      _appVersion.text = collector.appInfo?.appVersion ?? '';
      _manufacturer.text = collector.deviceInfo?.manufacturer ?? '';
      _modelNum.text = collector.deviceInfo?.modelNum ?? '';
      _devType.text = collector.deviceInfo?.devType ?? '';
      _uniqueId.text = collector.deviceInfo?.uniqueId ?? '';
      _deviceVersion.text = collector.deviceInfo?.version ?? '';
    });
  }

  void _submit() {
    if (!_formSecret.currentState!.validate()) return;

    setState(() {
      _hasSubmitted = true;
      _errorText = null;
    });

    ref.read(updateDataCollectorNotifierProvider.notifier).submit(
      GeneralDataCollectorResponseModel(
        collectorId: _selectedCollector!.collectorId,
        collectorName: _collectorName.text.trim(),
        collectorType: _collectorType.text.trim(),
        collectorDataType: CollectorDataType(name: _dataTypeName.text.trim()),
        lastUpdateTime: _selectedCollector!.lastUpdateTime,
        appInfo: AppInfo(
          appName: _appName.text.trim(),
          appVersion: _appVersion.text.trim(),
          desc: _appDesc.text.trim(),
          clientId: _clientId.text.trim(),
          appPackageName: _appPackageName.text.trim(),
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
    ref.listen(updateDataCollectorNotifierProvider, (previous, next) {
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
            SnackBar(content: Text('Collector updated: ${response.collectorId}')),
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

    final state = ref.watch(updateDataCollectorNotifierProvider);

    return HealthFormSheet(
      title: 'Update Data Collector',
      formKey: _formSecret,
      isSubmitting: state.isLoading,
      errorText: _errorText,
      onSubmit: _submit,
      submitLabel: 'Update',
      children: [
        DataCollectorPickerField(
          selectedId: _selectedCollector?.collectorId,
          onSelected: _onCollectorSelected,
        ),
        const SizedBox(height: 12),
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
          controller: _clientId,
          decoration: const InputDecoration(labelText: 'Client ID'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _appPackageName,
          decoration: const InputDecoration(labelText: 'Package name'),
        ),
        const SizedBox(height: 12),
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
          validator: requiredFieldValidator,
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
