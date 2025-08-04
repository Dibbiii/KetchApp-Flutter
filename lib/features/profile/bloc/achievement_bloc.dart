import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'package:ketchapp_flutter/models/achievement.dart';
import 'achievement_event.dart';
import 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;

  AchievementBloc({required ApiService apiService, required AuthBloc authBloc})
    : _apiService = apiService,
      _authBloc = authBloc,
      super(AchievementInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      emit(AchievementLoading());
      try {
        final achievements = await _apiService.getUserAchievements();
        emit(AchievementLoaded(achievements));
      } catch (e) {
        emit(AchievementError(e.toString()));
      }
    } else {
      emit(const AchievementError('User not authenticated'));
    }
  }
}
