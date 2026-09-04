int toNanoseconds(DateTime dateTime) => dateTime.microsecondsSinceEpoch * 1000;

DateTime fromNanoseconds(int nanoseconds) =>
    DateTime.fromMicrosecondsSinceEpoch(nanoseconds ~/ 1000);
