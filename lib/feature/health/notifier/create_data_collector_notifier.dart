import 'package:flutter_healthkit/core/network/model/general_data_collector_request_model.dart';
import 'package:flutter_healthkit/core/network/model/general_data_collector_response_model.dart';
import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createDataCollectorNotifierProvider = AutoDisposeAsyncNotifierProvider<
    CreateDataCollectorNotifier, GeneralDataCollectorResponseModel?>(
  CreateDataCollectorNotifier.new,
);

class CreateDataCollectorNotifier
    extends AutoDisposeAsyncNotifier<GeneralDataCollectorResponseModel?> {
  @override
  GeneralDataCollectorResponseModel? build() => null;

  Future<void> submit(GeneralDataCollectorRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(healthKitServiceProvider).createDataCollector(request),
    );
  }
}
