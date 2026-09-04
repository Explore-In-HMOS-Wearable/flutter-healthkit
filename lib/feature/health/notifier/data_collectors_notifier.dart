import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataCollectorsNotifierProvider = AsyncNotifierProvider<
    DataCollectorsNotifier, List<GeneralDataCollectorResponseModel>>(
  DataCollectorsNotifier.new,
);

class DataCollectorsNotifier
    extends AsyncNotifier<List<GeneralDataCollectorResponseModel>> {
  @override
  Future<List<GeneralDataCollectorResponseModel>> build() {
    return ref.read(healthKitServiceProvider).queryDataCollectors();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<GeneralDataCollectorResponseModel>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(healthKitServiceProvider).queryDataCollectors(),
    );
  }

  void addOrUpdate(GeneralDataCollectorResponseModel collector) {
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere(
      (c) => c.collectorId == collector.collectorId,
    );
    final updated = [...current];
    if (index >= 0) {
      updated[index] = collector;
    } else {
      updated.add(collector);
    }
    state = AsyncData(updated);
  }

  void remove(String collectorId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.where((c) => c.collectorId != collectorId).toList(),
    );
  }
}
