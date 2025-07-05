// ignore_for_file: constant_identifier_names

enum ActivityType {
  TIMER,
  BREAK,
}

extension ActivityTypeExtension on ActivityType {
  String toShortString() {
    return toString().split('.').last;
  }
}