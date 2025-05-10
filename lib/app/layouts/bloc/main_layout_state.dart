part of 'main_layout_bloc.dart';

class MainLayoutState {
  final bool isOverlayVisible;

  const MainLayoutState({this.isOverlayVisible = false});

  MainLayoutState copyWith({bool? isOverlayVisible}) {
    return MainLayoutState(
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
    );
  }
}