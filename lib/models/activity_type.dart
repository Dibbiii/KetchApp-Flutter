enum ActivityType {
  TIMER,
  BREAK,
}

extension ActivityTypeExtension on ActivityType {
  String toShortString() {
    return toString().split('.').last;
  }
}