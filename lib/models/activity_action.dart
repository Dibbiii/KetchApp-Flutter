// ignore_for_file: constant_identifier_names

enum ActivityAction {
  START,
  END,
  PAUSE,
  RESUME;

  String toShortString() {
    return toString().split('.').last;
  }
}
