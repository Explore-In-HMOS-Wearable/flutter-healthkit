import 'package:flutter_healthkit/core/network/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthKitServiceProvider = Provider<HealthKitService>((ref) {
  return HealthKitService();
});
