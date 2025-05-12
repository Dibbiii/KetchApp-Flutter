part of 'main_layout_bloc.dart';

/// State class for the main layout.
///
/// Contains properties that represent the UI state of the main layout.
class MainLayoutState {
  /// Whether the overlay menu is currently visible.
  final bool isOverlayVisible;

  const MainLayoutState({this.isOverlayVisible = false});

  /// Creates a copy of this state with the given fields replaced with new values.
  MainLayoutState copyWith({bool? isOverlayVisible}) {
    return MainLayoutState(
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
    );
  }
}
