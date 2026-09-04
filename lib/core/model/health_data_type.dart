const healthRecordTypePrefix = 'com.huawei.health';

enum HealthDataType {
  steps('com.huawei.continuous.steps.delta'),
  heartRate('com.huawei.instantaneous.heart_rate'),
  sleep('com.huawei.health.record.sleep');

  const HealthDataType(this.dataTypeName);

  final String dataTypeName;
}
