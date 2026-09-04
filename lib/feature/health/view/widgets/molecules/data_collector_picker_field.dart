import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataCollectorPickerField extends ConsumerWidget {
  const DataCollectorPickerField({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.label = 'Data collector',
    this.filter,
  });

  final String? selectedId;
  final ValueChanged<GeneralDataCollectorResponseModel> onSelected;
  final String label;

  final bool Function(GeneralDataCollectorResponseModel collector)? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataCollectorsNotifierProvider);

    return state.when(
      loading: () => InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const SizedBox(
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, _) => _RetryRow(
        message: 'Could not load data collectors.',
        onRetry: () => ref.read(dataCollectorsNotifierProvider.notifier).refresh(),
      ),
      data: (allCollectors) {
        final collectors =
            filter == null ? allCollectors : allCollectors.where(filter!).toList();
        if (collectors.isEmpty) {
          return _RetryRow(
            message: 'No data collectors found. Create one first.',
            onRetry: () => ref.read(dataCollectorsNotifierProvider.notifier).refresh(),
          );
        }

        final validSelectedId = collectors.any((c) => c.collectorId == selectedId)
            ? selectedId
            : null;

        return DropdownButtonFormField<String>(
          initialValue: validSelectedId,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(dataCollectorsNotifierProvider.notifier).refresh(),
            ),
          ),
          isExpanded: true,
          items: collectors.map((collector) {
            return DropdownMenuItem(
              value: collector.collectorId,
              child: Text(
                collector.collectorName ?? collector.collectorId ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (id) {
            final collector = collectors.firstWhere((c) => c.collectorId == id);
            onSelected(collector);
          },
          validator: (value) => value == null ? 'Required' : null,
        );
      },
    );
  }
}

class _RetryRow extends StatelessWidget {
  const _RetryRow({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(message, style: TextStyle(color: colorScheme.error)),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Retry',
          onPressed: onRetry,
        ),
      ],
    );
  }
}
