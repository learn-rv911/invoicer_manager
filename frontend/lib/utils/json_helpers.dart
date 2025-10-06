// lib/utils/json_helpers.dart
DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

DateTime? parseDate(dynamic v) => parseDateTime(v);
