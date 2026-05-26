/// Converts [value] to an ISO-8601 UTC string with a trailing `Z`.
String dateTimeToIso8601Utc(DateTime value) => value.toUtc().toIso8601String();

/// Parses an ISO-8601 UTC string with a required trailing `Z`.
DateTime parseUtcDateTime(Object? value, String fieldName) {
  if (value is! String) {
    throw FormatException(
      '$fieldName must be an ISO-8601 UTC string.',
      value,
    );
  }

  if (!value.endsWith('Z')) {
    throw FormatException(
      '$fieldName must be an ISO-8601 UTC string ending in Z.',
      value,
    );
  }

  return DateTime.parse(value).toUtc();
}
