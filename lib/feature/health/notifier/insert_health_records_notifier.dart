import 'package:flutter_healthkit/core/network/model/general_data_collector_request_model.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final insertHealthRecordsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    InsertHealthRecordsNotifier, GeneralDataCollectorPatchResponseModel?>(
  InsertHealthRecordsNotifier.new,
);

class InsertHealthRecordsNotifier
    extends AutoDisposeAsyncNotifier<GeneralDataCollectorPatchResponseModel?> {
  @override
  GeneralDataCollectorPatchResponseModel? build() => null;

  Future<void> submit({
    required String dataCollectorId,
    required GeneralDataCollectorPatchRequestModel request,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(healthKitServiceProvider)
          .insertHealthRecords(dataCollectorId, request),
    );
  }
}
