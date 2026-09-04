class DetailRecordEntry {
  const DetailRecordEntry({
    required this.dataTypeName,
    required this.startTime,
    required this.endTime,
    required this.fields,
    this.subDataRelationSummaries = const [],
  });

  final String? dataTypeName;
  final int? startTime;
  final int? endTime;
  final List<DetailFieldValue> fields;
  final List<String> subDataRelationSummaries;
}

class DetailFieldValue {
  const DetailFieldValue({required this.fieldName, required this.displayValue});

  final String? fieldName;
  final String displayValue;
}
