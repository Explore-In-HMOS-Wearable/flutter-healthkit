import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteDataCollectorNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DeleteDataCollectorNotifier, bool?>(
  DeleteDataCollectorNotifier.new,
);

class DeleteDataCollectorNotifier extends AutoDisposeAsyncNotifier<bool?> {
  @override
  bool? build() => null;

  Future<void> submit(String dataCollectorId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(healthKitServiceProvider)
          .deleteDataCollector(dataCollectorId: dataCollectorId),
    );
  }
}
