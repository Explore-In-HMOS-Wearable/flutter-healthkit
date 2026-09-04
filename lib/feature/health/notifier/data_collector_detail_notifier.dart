import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/network/model/health_records_query_response_model.dart';
import 'package:flutter_healthkit/core/network/model/sample_sets_history_response_model.dart';
import 'package:flutter_healthkit/core/model/detail_record_entry.dart';
import 'package:flutter_healthkit/core/model/health_data_type.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_healthkit/feature/health/util/nanoseconds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataCollectorDetailNotifierProvider = AsyncNotifierProvider.family<
    DataCollectorDetailNotifier, List<DetailRecordEntry>, String>(
  DataCollectorDetailNotifier.new,
);

class DataCollectorDetailNotifier
    extends FamilyAsyncNotifier<List<DetailRecordEntry>, String> {
  static final _defaultStart = DateTime.now().subtract(const Duration(days: 365));
  static final _defaultEnd = DateTime.now();

  @override
  Future<List<DetailRecordEntry>> build(String dataCollectorId) {
    return _query(dataCollectorId, _defaultStart, _defaultEnd);
  }

  Future<void> query({required DateTime start, required DateTime end}) async {
    state = const AsyncLoading<List<DetailRecordEntry>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _query(arg, start, end));
  }

  Future<List<DetailRecordEntry>> _query(
    String dataCollectorId,
    DateTime start,
    DateTime end,
  ) async {
    final collectors = await ref.read(dataCollectorsNotifierProvider.future);
    final dataTypeName = _findDataTypeName(collectors, dataCollectorId);
    final service = ref.read(healthKitServiceProvider);

    if (dataTypeName != null && dataTypeName.startsWith(healthRecordTypePrefix)) {
      final response = await service.queryHealthRecords(
        dataCollectorId: dataCollectorId,
        startTime: toNanoseconds(start),
        endTime: toNanoseconds(end),
      );
      return _fromHealthRecords(response);
    }

    final response = await service.querySampleSetsHistory(dataCollectorId);
    return _fromSampleSetsHistory(response);
  }

  String? _findDataTypeName(
    List<GeneralDataCollectorResponseModel> collectors,
    String dataCollectorId,
  ) {
    for (final collector in collectors) {
      if (collector.collectorId == dataCollectorId) {
        return collector.collectorDataType?.name;
      }
    }
    return null;
  }

  List<DetailRecordEntry> _fromHealthRecords(
    HealthRecordsQueryResponseModel? response,
  ) {
    final records = response?.healthRecords ?? [];
    return records.map((record) {
      return DetailRecordEntry(
        dataTypeName: record.dataTypeName,
        startTime: record.startTime,
        endTime: record.endTime,
        fields: (record.value ?? []).map((value) {
          return DetailFieldValue(
            fieldName: value.fieldName,
            displayValue: _formatValue(
              stringValue: value.stringValue,
              integerValue: value.integerValue,
              longValue: value.longValue,
            ),
          );
        }).toList(),
        subDataRelationSummaries: (record.subDataRelation ?? []).map((relation) {
          return '${relation.dataTypeName} · ${_formatTime(relation.startTime)} — ${_formatTime(relation.endTime)}';
        }).toList(),
      );
    }).toList();
  }

  List<DetailRecordEntry> _fromSampleSetsHistory(
    SampleSetsHistoryResponseModel? response,
  ) {
    final points = response?.insertedSamplePoint ?? const [];
    return points.map((point) {
      return DetailRecordEntry(
        dataTypeName: point.dataTypeName,
        startTime: point.startTime,
        endTime: point.endTime,
        fields: (point.value ?? []).map((value) {
          return DetailFieldValue(
            fieldName: value.fieldName,
            displayValue: _formatValue(
              stringValue: value.stringValue,
              integerValue: value.integerValue,
              longValue: value.longValue,
              floatValue: value.floatValue,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  String _formatValue({
    String? stringValue,
    int? integerValue,
    int? longValue,
    num? floatValue,
  }) {
    if (stringValue != null) return stringValue;
    if (longValue != null) return longValue.toString();
    if (integerValue != null) return integerValue.toString();
    if (floatValue != null) return floatValue.toString();
    return '-';
  }

  String _formatTime(int? nanoseconds) {
    if (nanoseconds == null) return '-';
    return '${fromNanoseconds(nanoseconds).toLocal()}'.substring(0, 16);
  }
}
