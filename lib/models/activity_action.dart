enum ActivityAction {
  START,
  END,
  PAUSE,
  RESUME;

  String toShortString() {
    return toString().split('.').last;
  }
}
