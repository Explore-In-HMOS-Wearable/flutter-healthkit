class GeneralDataCollectorResponseModel {
  String? collectorId;
  String? collectorName;
  String? collectorType;
  CollectorDataType? collectorDataType;
  DeviceInfo? deviceInfo;
  AppInfo? appInfo;
  int? lastUpdateTime;

  GeneralDataCollectorResponseModel({
    this.collectorId,
    this.collectorName,
    this.collectorType,
    this.collectorDataType,
    this.deviceInfo,
    this.appInfo,
    this.lastUpdateTime,
  });

  GeneralDataCollectorResponseModel.fromJson(Map<String, dynamic> json) {
    collectorId = json['collectorId'];
    collectorName = json['collectorName'];
    collectorType = json['collectorType'];
    collectorDataType = json['collectorDataType'] != null
        ? new CollectorDataType.fromJson(json['collectorDataType'])
        : null;
    deviceInfo = json['deviceInfo'] != null
        ? new DeviceInfo.fromJson(json['deviceInfo'])
        : null;
    appInfo = json['appInfo'] != null
        ? new AppInfo.fromJson(json['appInfo'])
        : null;
    lastUpdateTime = json['lastUpdateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectorId'] = this.collectorId;
    data['collectorName'] = this.collectorName;
    data['collectorType'] = this.collectorType;
    if (this.collectorDataType != null) {
      data['collectorDataType'] = this.collectorDataType!.toJson();
    }
    if (this.deviceInfo != null) {
      data['deviceInfo'] = this.deviceInfo!.toJson();
    }
    if (this.appInfo != null) {
      data['appInfo'] = this.appInfo!.toJson();
    }
    data['lastUpdateTime'] = this.lastUpdateTime;
    return data;
  }
}

class CollectorDataType {
  String? name;
  List<Field>? field;

  CollectorDataType({this.name, this.field});

  CollectorDataType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['field'] != null) {
      field = <Field>[];
      json['field'].forEach((v) {
        field!.add(new Field.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.field != null) {
      data['field'] = this.field!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Field {
  String? name;
  String? format;
  bool? optional;

  Field({this.name, this.format, this.optional});

  Field.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    format = json['format'];
    optional = json['optional'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['format'] = this.format;
    data['optional'] = this.optional;
    return data;
  }
}

class DeviceInfo {
  String? uniqueId;
  String? devType;
  String? version;
  String? modelNum;
  String? manufacturer;

  DeviceInfo({
    this.uniqueId,
    this.devType,
    this.version,
    this.modelNum,
    this.manufacturer,
  });

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    uniqueId = json['uniqueId'];
    devType = json['devType'];
    version = json['version'];
    modelNum = json['modelNum'];
    manufacturer = json['manufacturer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uniqueId'] = this.uniqueId;
    data['devType'] = this.devType;
    data['version'] = this.version;
    data['modelNum'] = this.modelNum;
    data['manufacturer'] = this.manufacturer;
    return data;
  }
}

class AppInfo {
  String? appName;
  String? appVersion;
  String? desc;
  String? clientId;
  String? appPackageName;

  AppInfo({
    this.appName,
    this.appVersion,
    this.desc,
    this.clientId,
    this.appPackageName,
  });

  AppInfo.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    appVersion = json['appVersion'];
    desc = json['desc'];
    clientId = json['clientId'];
    appPackageName = json['appPackageName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appName'] = this.appName;
    data['appVersion'] = this.appVersion;
    data['desc'] = this.desc;
    data['clientId'] = this.clientId;
    if (this.appPackageName != null && this.appPackageName!.isNotEmpty) {
      data['appPackageName'] = this.appPackageName;
    }
    return data;
  }
}

class GeneralDataCollectorPatchResponseModel {
  List<HealthRecords>? healthRecords;

  GeneralDataCollectorPatchResponseModel({this.healthRecords});

  GeneralDataCollectorPatchResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? timezone;

  HealthRecords({
    this.dataTypeName,
    this.endTime,
    this.startTime,
    this.value,
    this.subDataRelation,
    this.id,
    this.timezone,
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
    id = json['id'];
    timezone = json['timezone'];
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
    data['id'] = this.id;
    data['timezone'] = this.timezone;
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
    data['integerValue'] = this.integerValue;
    data['longValue'] = this.longValue;
    data['stringValue'] = this.stringValue;
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
