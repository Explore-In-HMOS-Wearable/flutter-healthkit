class SampleSetsHistoryResponseModel {
  List<SampleSetHistoryPoint>? insertedSamplePoint;
  List<SampleSetHistoryPoint>? deletedSamplePoint;
  String? cursor;
  String? dataCollectorId;
  bool? hasMoreData;

  SampleSetsHistoryResponseModel({
    this.insertedSamplePoint,
    this.deletedSamplePoint,
    this.cursor,
    this.dataCollectorId,
    this.hasMoreData,
  });

  SampleSetsHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['insertedSamplePoint'] != null) {
      insertedSamplePoint = <SampleSetHistoryPoint>[];
      json['insertedSamplePoint'].forEach((v) {
        insertedSamplePoint!.add(SampleSetHistoryPoint.fromJson(v));
      });
    }
    if (json['deletedSamplePoint'] != null) {
      deletedSamplePoint = <SampleSetHistoryPoint>[];
      json['deletedSamplePoint'].forEach((v) {
        deletedSamplePoint!.add(SampleSetHistoryPoint.fromJson(v));
      });
    }
    cursor = json['cursor'];
    dataCollectorId = json['dataCollectorId'];
    hasMoreData = json['hasMoreData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (insertedSamplePoint != null) {
      data['insertedSamplePoint'] =
          insertedSamplePoint!.map((v) => v.toJson()).toList();
    }
    if (deletedSamplePoint != null) {
      data['deletedSamplePoint'] =
          deletedSamplePoint!.map((v) => v.toJson()).toList();
    }
    data['cursor'] = cursor;
    data['dataCollectorId'] = dataCollectorId;
    data['hasMoreData'] = hasMoreData;
    return data;
  }
}

class SampleSetHistoryPoint {
  int? startTime;
  int? endTime;
  String? dataTypeName;
  String? originalDataCollectorId;
  List<SampleSetHistoryValue>? value;
  int? modifyTime;

  SampleSetHistoryPoint({
    this.startTime,
    this.endTime,
    this.dataTypeName,
    this.originalDataCollectorId,
    this.value,
    this.modifyTime,
  });

  SampleSetHistoryPoint.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    dataTypeName = json['dataTypeName'];
    originalDataCollectorId = json['originalDataCollectorId'];
    if (json['value'] != null) {
      value = <SampleSetHistoryValue>[];
      json['value'].forEach((v) {
        value!.add(SampleSetHistoryValue.fromJson(v));
      });
    }
    modifyTime = json['modifyTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['dataTypeName'] = dataTypeName;
    data['originalDataCollectorId'] = originalDataCollectorId;
    if (value != null) {
      data['value'] = value!.map((v) => v.toJson()).toList();
    }
    data['modifyTime'] = modifyTime;
    return data;
  }
}

class SampleSetHistoryValue {
  String? fieldName;
  int? integerValue;
  int? longValue;
  num? floatValue;
  String? stringValue;

  SampleSetHistoryValue({
    this.fieldName,
    this.integerValue,
    this.longValue,
    this.floatValue,
    this.stringValue,
  });

  SampleSetHistoryValue.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    integerValue = json['integerValue'];
    longValue = json['longValue'];
    floatValue = json['floatValue'];
    stringValue = json['stringValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fieldName'] = fieldName;
    if (integerValue != null) data['integerValue'] = integerValue;
    if (longValue != null) data['longValue'] = longValue;
    if (floatValue != null) data['floatValue'] = floatValue;
    if (stringValue != null) data['stringValue'] = stringValue;
    return data;
  }
}
