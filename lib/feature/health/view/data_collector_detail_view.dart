import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/model/detail_record_entry.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collector_detail_notifier.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/feature/health/notifier/delete_data_collector_notifier.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/atoms/date_time_field.dart';
import 'package:flutter_healthkit/feature/health/view/widgets/organisms/health_form_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class DataCollectorDetailView extends ConsumerStatefulWidget {
  const DataCollectorDetailView({super.key, required this.collectorId});

  final String collectorId;

  @override
  ConsumerState<DataCollectorDetailView> createState() =>
      _DataCollectorDetailViewState();
}

class _DataCollectorDetailViewState
    extends ConsumerState<DataCollectorDetailView> {
  var _startTime = DateTime.now().subtract(const Duration(days: 365));
  var _endTime = DateTime.now();
  var _hasSubmittedDelete = false;

  GeneralDataCollectorResponseModel? _findCollector(
    List<GeneralDataCollectorResponseModel> collectors,
  ) {
    for (final collector in collectors) {
      if (collector.collectorId == widget.collectorId) return collector;
    }
    return null;
  }

  void _query() {
    ref
        .read(dataCollectorDetailNotifierProvider(widget.collectorId).notifier)
        .query(start: _startTime, end: _endTime);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete this data collector.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _hasSubmittedDelete = true);
    ref.read(deleteDataCollectorNotifierProvider.notifier).submit(widget.collectorId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final collectors = ref.watch(dataCollectorsNotifierProvider).valueOrNull ?? [];
    final collector = _findCollector(collectors);
    final recordsState =
        ref.watch(dataCollectorDetailNotifierProvider(widget.collectorId));

    ref.listen(deleteDataCollectorNotifierProvider, (previous, next) {
      if (!_hasSubmittedDelete || next.isLoading) return;
      next.when(
        data: (success) {
          if (success != true) {
            showHealthErrorSnackBar(context, 'Request failed. Please try again.');
            return;
          }
          ref.read(dataCollectorsNotifierProvider.notifier).remove(widget.collectorId);
          Navigator.of(context).pop();
        },
        error: (error, _) => showHealthErrorSnackBar(context, error.toString()),
        loading: () {},
      );
    });

    final isDeleting = ref.watch(deleteDataCollectorNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(collector?.collectorName ?? 'Data Collector'),
        actions: [
          IconButton(
            onPressed: isDeleting ? null : _confirmDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            tooltip: 'Delete data collector',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _query(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (collector != null)
              _CollectorInfoCard(collector: collector, colorScheme: colorScheme),
            const SizedBox(height: 16),
            _TimeRangeSection(
              startTime: _startTime,
              endTime: _endTime,
              onStartChanged: (value) => setState(() => _startTime = value),
              onEndChanged: (value) => setState(() => _endTime = value),
              onQuery: _query,
              isQuerying: recordsState.isLoading,
            ),
            const SizedBox(height: 16),
            recordsState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _MessageCard(
                colorScheme: colorScheme,
                message: error.toString(),
                isError: true,
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return _MessageCard(
                    colorScheme: colorScheme,
                    message: 'No records found for this range.',
                    isError: false,
                  );
                }
                return Column(
                  children: [
                    for (final entry in entries)
                      _DetailRecordCard(entry: entry, colorScheme: colorScheme),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorInfoCard extends StatelessWidget {
  const _CollectorInfoCard({required this.collector, required this.colorScheme});

  final GeneralDataCollectorResponseModel collector;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Collector ID', value: collector.collectorId ?? '-'),
          _InfoRow(label: 'Type', value: collector.collectorType ?? '-'),
          _InfoRow(label: 'Data type', value: collector.collectorDataType?.name ?? '-'),
          if (collector.deviceInfo?.manufacturer != null ||
              collector.deviceInfo?.modelNum != null)
            _InfoRow(
              label: 'Device',
              value:
                  '${collector.deviceInfo?.manufacturer ?? ''} ${collector.deviceInfo?.modelNum ?? ''}'
                      .trim(),
            ),
          if (collector.appInfo?.appName != null)
            _InfoRow(label: 'App', value: collector.appInfo!.appName!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRangeSection extends StatelessWidget {
  const _TimeRangeSection({
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onQuery,
    required this.isQuerying,
  });

  final DateTime startTime;
  final DateTime endTime;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;
  final VoidCallback onQuery;
  final bool isQuerying;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateTimeField(label: 'Start time', value: startTime, onChanged: onStartChanged),
        const SizedBox(height: 12),
        DateTimeField(label: 'End time', value: endTime, onChanged: onEndChanged),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: isQuerying ? null : onQuery,
          child: isQuerying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Query'),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.colorScheme,
    required this.message,
    required this.isError,
  });

  final ColorScheme colorScheme;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DetailRecordCard extends StatelessWidget {
  const _DetailRecordCard({required this.entry, required this.colorScheme});

  final DetailRecordEntry entry;
  final ColorScheme colorScheme;

  String _formatTime(int? nanoseconds) {
    if (nanoseconds == null) return '-';
    final dateTime = DateTime.fromMicrosecondsSinceEpoch(nanoseconds ~/ 1000);
    return '${dateTime.toLocal()}'.substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.dataTypeName ?? 'Unknown data type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatTime(entry.startTime)} — ${_formatTime(entry.endTime)}',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.fields.map((field) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${field.fieldName}: ${field.displayValue}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              );
            }).toList(),
          ),
          if (entry.subDataRelationSummaries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'SUB DATA RELATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            for (final summary in entry.subDataRelationSummaries)
              Text(
                summary,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ],
      ),
    );
  }
}
