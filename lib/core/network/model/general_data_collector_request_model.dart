class GeneralDataCollectorRequestModel {
  String? collectorName;
  String? collectorType;
  AppInfo? appInfo;
  CollectorDataType? collectorDataType;
  DeviceInfo? deviceInfo;

  GeneralDataCollectorRequestModel({
    this.collectorName,
    this.collectorType,
    this.appInfo,
    this.collectorDataType,
    this.deviceInfo,
  });

  GeneralDataCollectorRequestModel.fromJson(Map<String, dynamic> json) {
    collectorName = json['collectorName'];
    collectorType = json['collectorType'];
    appInfo = json['appInfo'] != null
        ? new AppInfo.fromJson(json['appInfo'])
        : null;
    collectorDataType = json['collectorDataType'] != null
        ? new CollectorDataType.fromJson(json['collectorDataType'])
        : null;
    deviceInfo = json['deviceInfo'] != null
        ? new DeviceInfo.fromJson(json['deviceInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectorName'] = this.collectorName;
    data['collectorType'] = this.collectorType;
    if (this.appInfo != null) {
      data['appInfo'] = this.appInfo!.toJson();
    }
    if (this.collectorDataType != null) {
      data['collectorDataType'] = this.collectorDataType!.toJson();
    }
    if (this.deviceInfo != null) {
      data['deviceInfo'] = this.deviceInfo!.toJson();
    }
    return data;
  }
}

class AppInfo {
  String? appName;
  String? desc;
  String? appVersion;

  AppInfo({this.appName, this.desc, this.appVersion});

  AppInfo.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    desc = json['desc'];
    appVersion = json['appVersion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appName'] = this.appName;
    data['desc'] = this.desc;
    data['appVersion'] = this.appVersion;
    return data;
  }
}

class CollectorDataType {
  String? name;

  CollectorDataType({this.name});

  CollectorDataType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

class DeviceInfo {
  String? manufacturer;
  String? modelNum;
  String? devType;
  String? uniqueId;
  String? version;

  DeviceInfo({
    this.manufacturer,
    this.modelNum,
    this.devType,
    this.uniqueId,
    this.version,
  });

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    manufacturer = json['manufacturer'];
    modelNum = json['modelNum'];
    devType = json['devType'];
    uniqueId = json['uniqueId'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['manufacturer'] = this.manufacturer;
    data['modelNum'] = this.modelNum;
    data['devType'] = this.devType;
    data['uniqueId'] = this.uniqueId;
    data['version'] = this.version;
    return data;
  }
}

class GeneralDataCollectorPatchRequestModel {
  List<HealthRecords>? healthRecords;

  GeneralDataCollectorPatchRequestModel({this.healthRecords});

  GeneralDataCollectorPatchRequestModel.fromJson(Map<String, dynamic> json) {
    if (json['healthRecords'] != null) {
      healthRecords = <HealthRecords>[];
      json['healthRecords'].forEach((v) {
        healthRecords!.add(new HealthRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.healthRecords != null) {
      data['healthRecords'] = this.healthRecords!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class HealthRecords {
  String? dataTypeName;
  int? endTime;
  int? startTime;
  List<Value>? value;
  List<SubDataRelation>? subDataRelation;

  HealthRecords({
    this.dataTypeName,
    this.endTime,
    this.startTime,
    this.value,
    this.subDataRelation,
  });

  HealthRecords.fromJson(Map<String, dynamic> json) {
    dataTypeName = json['dataTypeName'];
    endTime = json['endTime'];
    startTime = json['startTime'];
    if (json['value'] != null) {
      value = <Value>[];
      json['value'].forEach((v) {
        value!.add(new Value.fromJson(v));
      });
    }
    if (json['subDataRelation'] != null) {
      subDataRelation = <SubDataRelation>[];
      json['subDataRelation'].forEach((v) {
        subDataRelation!.add(new SubDataRelation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataTypeName'] = this.dataTypeName;
    data['endTime'] = this.endTime;
    data['startTime'] = this.startTime;
    if (this.value != null) {
      data['value'] = this.value!.map((v) => v.toJson()).toList();
    }
    if (this.subDataRelation != null) {
      data['subDataRelation'] = this.subDataRelation!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class Value {
  String? fieldName;
  int? integerValue;
  int? longValue;
  String? stringValue;

  Value({this.fieldName, this.integerValue, this.longValue, this.stringValue});

  Value.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    integerValue = json['integerValue'];
    longValue = json['longValue'];
    stringValue = json['stringValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fieldName'] = this.fieldName;
    if (this.integerValue != null) data['integerValue'] = this.integerValue;
    if (this.longValue != null) data['longValue'] = this.longValue;
    if (this.stringValue != null) data['stringValue'] = this.stringValue;
    return data;
  }
}

class SubDataRelation {
  int? startTime;
  int? endTime;
  String? dataTypeName;
  String? dataCollectorId;

  SubDataRelation({
    this.startTime,
    this.endTime,
    this.dataTypeName,
    this.dataCollectorId,
  });

  SubDataRelation.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    dataTypeName = json['dataTypeName'];
    dataCollectorId = json['dataCollectorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['dataTypeName'] = this.dataTypeName;
    data['dataCollectorId'] = this.dataCollectorId;
    return data;
  }
}
