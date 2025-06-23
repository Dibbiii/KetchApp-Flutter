import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/services/api_service.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';
import '../presentation/ranking_page.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final ApiService apiService;

  RankingBloc({required this.apiService}) : super(RankingInitial()) {
    on<LoadRanking>(_onLoadRanking);
    on<RefreshRanking>(_onRefreshRanking);
    on<ChangeRankingFilter>(_onChangeRankingFilter);
  }

  Future<void> _onLoadRanking(
    LoadRanking event,
    Emitter<RankingState> emit,
  ) async {
    emit(RankingLoading());
    try {
      final usersJson = await apiService.getUsersForRanking();
      usersJson.sort((a, b) => (b['totalHours'] as num).compareTo(a['totalHours'] as num));
      final users = usersJson.asMap().entries.map((entry) {
        int rank = entry.key + 1;
        Map<String, dynamic> userJson = entry.value;
        return UserRankData.fromJson(userJson, rank);
      }).toList();
      emit(RankingLoaded(users, RankingFilter.hours));
    } catch (e) {
      emit(RankingError(e.toString()));
    }
  }

  Future<void> _onRefreshRanking(
    RefreshRanking event,
    Emitter<RankingState> emit,
  ) async {
    try {
      final usersJson = await apiService.getUsersForRanking();
      usersJson.sort((a, b) => (b['totalHours'] as num).compareTo(a['totalHours'] as num));
      final users = usersJson.asMap().entries.map((entry) {
        int rank = entry.key + 1;
        Map<String, dynamic> userJson = entry.value;
        return UserRankData.fromJson(userJson, rank);
      }).toList();
      emit(RankingLoaded(users, RankingFilter.hours));
    } catch (e) {
      emit(RankingError(e.toString()));
    }
  }

  void _onChangeRankingFilter(
    ChangeRankingFilter event,
    Emitter<RankingState> emit,
  ) {
    if (state is RankingLoaded) {
      final loaded = state as RankingLoaded;
      emit(RankingLoaded(loaded.users, event.filter));
    }
  }
}
