import 'package:flutter_healthkit/core/network/model/sample_data_upload_request_model.dart';
import 'package:flutter_healthkit/core/network/model/sample_data_upload_response_model.dart';
import 'package:flutter_healthkit/core/service/health_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadSampleDataNotifierProvider = AutoDisposeAsyncNotifierProvider<
    UploadSampleDataNotifier, SampleDataUploadPatchResponseModel?>(
  UploadSampleDataNotifier.new,
);

class UploadSampleDataNotifier
    extends AutoDisposeAsyncNotifier<SampleDataUploadPatchResponseModel?> {
  @override
  SampleDataUploadPatchResponseModel? build() => null;

  Future<void> submit({
    required String dataCollectorId,
    required String sampleSetId,
    required SampleDataUploadPatchRequestModel request,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(healthKitServiceProvider)
          .uploadSampleData(dataCollectorId, sampleSetId, request),
    );
  }
}
