class SampleDataUploadPatchRequestModel {
  String? dataCollectorId;
  int? startTime;
  int? endTime;
  List<SamplePoints>? samplePoints;

  SampleDataUploadPatchRequestModel({
    this.dataCollectorId,
    this.startTime,
    this.endTime,
    this.samplePoints,
  });

  SampleDataUploadPatchRequestModel.fromJson(Map<String, dynamic> json) {
    dataCollectorId = json['dataCollectorId'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    if (json['samplePoints'] != null) {
      samplePoints = <SamplePoints>[];
      json['samplePoints'].forEach((v) {
        samplePoints!.add(new SamplePoints.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataCollectorId'] = this.dataCollectorId;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    if (this.samplePoints != null) {
      data['samplePoints'] = this.samplePoints!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SamplePoints {
  String? dataTypeName;
  int? endTime;
  int? startTime;
  List<Value>? value;

  SamplePoints({this.dataTypeName, this.endTime, this.startTime, this.value});

  SamplePoints.fromJson(Map<String, dynamic> json) {
    dataTypeName = json['dataTypeName'];
    endTime = json['endTime'];
    startTime = json['startTime'];
    if (json['value'] != null) {
      value = <Value>[];
      json['value'].forEach((v) {
        value!.add(new Value.fromJson(v));
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
    return data;
  }
}

class Value {
  String? fieldName;
  num? floatValue;
  String? stringValue;
  int? integerValue;

  Value({this.fieldName, this.floatValue, this.stringValue, this.integerValue});

  Value.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    floatValue = json['floatValue'];
    stringValue = json['stringValue'];
    integerValue = json['integerValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fieldName'] = this.fieldName;
    if (this.floatValue != null) data['floatValue'] = this.floatValue;
    if (this.stringValue != null) data['stringValue'] = this.stringValue;
    if (this.integerValue != null) data['integerValue'] = this.integerValue;
    return data;
  }
}
