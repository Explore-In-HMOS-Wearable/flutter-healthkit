class HealthRecordsQueryResponseModel {
  List<HealthRecordEntry>? healthRecords;

  HealthRecordsQueryResponseModel({this.healthRecords});

  HealthRecordsQueryResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['healthRecords'] != null) {
      healthRecords = <HealthRecordEntry>[];
      json['healthRecords'].forEach((v) {
        healthRecords!.add(HealthRecordEntry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (healthRecords != null) {
      data['healthRecords'] = healthRecords!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HealthRecordEntry {
  int? startTime;
  int? endTime;
  String? dataTypeName;
  List<HealthRecordValue>? value;
  int? modifyTime;
  String? id;
  List<HealthRecordSubDataRelation>? subDataRelation;

  HealthRecordEntry({
    this.startTime,
    this.endTime,
    this.dataTypeName,
    this.value,
    this.modifyTime,
    this.id,
    this.subDataRelation,
  });

  HealthRecordEntry.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    dataTypeName = json['dataTypeName'];
    if (json['value'] != null) {
      value = <HealthRecordValue>[];
      json['value'].forEach((v) {
        value!.add(HealthRecordValue.fromJson(v));
      });
    }
    modifyTime = json['modifyTime'];
    id = json['id'];
    if (json['subDataRelation'] != null) {
      subDataRelation = <HealthRecordSubDataRelation>[];
      json['subDataRelation'].forEach((v) {
        subDataRelation!.add(HealthRecordSubDataRelation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['dataTypeName'] = dataTypeName;
    if (value != null) {
      data['value'] = value!.map((v) => v.toJson()).toList();
    }
    data['modifyTime'] = modifyTime;
    data['id'] = id;
    if (subDataRelation != null) {
      data['subDataRelation'] = subDataRelation!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HealthRecordValue {
  String? fieldName;
  int? integerValue;
  int? longValue;
  String? stringValue;

  HealthRecordValue({
    this.fieldName,
    this.integerValue,
    this.longValue,
    this.stringValue,
  });

  HealthRecordValue.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    integerValue = json['integerValue'];
    longValue = json['longValue'];
    stringValue = json['stringValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fieldName'] = fieldName;
    if (integerValue != null) data['integerValue'] = integerValue;
    if (longValue != null) data['longValue'] = longValue;
    if (stringValue != null) data['stringValue'] = stringValue;
    return data;
  }
}

class HealthRecordSubDataRelation {
  int? startTime;
  int? endTime;
  String? dataTypeName;
  String? dataCollectorId;

  HealthRecordSubDataRelation({
    this.startTime,
    this.endTime,
    this.dataTypeName,
    this.dataCollectorId,
  });

  HealthRecordSubDataRelation.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    dataTypeName = json['dataTypeName'];
    dataCollectorId = json['dataCollectorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['dataTypeName'] = dataTypeName;
    data['dataCollectorId'] = dataCollectorId;
    return data;
  }
}
