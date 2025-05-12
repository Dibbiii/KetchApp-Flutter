import 'package:bloc/bloc.dart';

part 'main_layout_event.dart';
part 'main_layout_state.dart';

/// BLoC to manage the main layout's UI state.
///
/// Handles overlay visibility toggling and other layout-related state.
class MainLayoutBloc extends Bloc<MainLayoutEvent, MainLayoutState> {
  MainLayoutBloc() : super(const MainLayoutState()) {
    on<ToggleOverlayVisibility>(_onToggleOverlayVisibility);
  }

  void _onToggleOverlayVisibility(
    ToggleOverlayVisibility event,
    Emitter<MainLayoutState> emit,
  ) {
    emit(state.copyWith(isOverlayVisible: !state.isOverlayVisible));
  }
}
